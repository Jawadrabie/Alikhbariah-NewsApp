import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum InAppVideoViewMode { hidden, fullscreen, mini }

class InAppVideoController extends ChangeNotifier {
  InAppVideoController._();

  static final InAppVideoController instance = InAppVideoController._();

  WebViewController? _webViewController;
  String _title = '';
  bool _hasPlaybackError = false;
  String _playbackErrorMessage = '';
  InAppVideoViewMode _viewMode = InAppVideoViewMode.hidden;

  WebViewController? get webViewController => _webViewController;
  String get title => _title;
  InAppVideoViewMode get viewMode => _viewMode;
  bool get hasPlaybackError => _hasPlaybackError;
  String get playbackErrorMessage => _playbackErrorMessage;
  bool get isMiniPlayerVisible =>
      _viewMode == InAppVideoViewMode.mini && _webViewController != null;
  bool get isFullscreenVisible =>
      _viewMode == InAppVideoViewMode.fullscreen && _webViewController != null;

  static String? extractYoutubeId(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    if (host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty
          ? _normalizeId(uri.pathSegments.first)
          : null;
    }

    if (uri.queryParameters['v'] != null) {
      return _normalizeId(uri.queryParameters['v']!);
    }

    final segments = uri.pathSegments;
    final embedIndex = segments.indexOf('embed');
    if (embedIndex != -1 && segments.length > embedIndex + 1) {
      return _normalizeId(segments[embedIndex + 1]);
    }

    final shortsIndex = segments.indexOf('shorts');
    if (shortsIndex != -1 && segments.length > shortsIndex + 1) {
      return _normalizeId(segments[shortsIndex + 1]);
    }

    final liveIndex = segments.indexOf('live');
    if (liveIndex != -1 && segments.length > liveIndex + 1) {
      return _normalizeId(segments[liveIndex + 1]);
    }

    return null;
  }

  static String? _normalizeId(String id) {
    final cleaned = id.split('&').first.split('?').first.trim();
    if (cleaned.isEmpty) return null;
    return cleaned;
  }

  Uri _embedUriFor(String videoId) {
    return Uri.parse(
      'https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1&rel=0&modestbranding=1&controls=0&fs=0&disablekb=1&iv_load_policy=3',
    );
  }

  NavigationDecision _handleNavigation(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return NavigationDecision.prevent;

    if (uri.scheme == 'about' || uri.scheme == 'data') {
      return NavigationDecision.navigate;
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return NavigationDecision.prevent;
    }

    final host = uri.host.toLowerCase();

    // Allow YouTube domains
    final isYoutubeHost =
        host.contains('youtube.com') ||
        host.contains('youtube-nocookie.com') ||
        host.contains('youtu.be') ||
        host.contains('googlevideo.com');

    // Allow Google accounts for login/auth flows which might be needed
    final isGoogleAuth =
        host.contains('accounts.google.com') || host.contains('google.com');

    if (isYoutubeHost || isGoogleAuth) {
      return NavigationDecision.navigate;
    }

    return NavigationDecision.prevent;
  }

  WebViewController _buildWebViewController() {
    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) => _handleNavigation(request.url),
              onWebResourceError: (error) {
                // Only report error if it's a main frame failure or similar major issue
                if (error.isForMainFrame == true) {
                  _hasPlaybackError = true;
                  _playbackErrorMessage =
                      'تعذر تشغيل الفيديو. قد يكون التضمين معطّل من المصدر.';
                  notifyListeners();
                }
              },
            ),
          );

    if (Platform.isAndroid && controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(false);
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    controller.setUserAgent(
      'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36',
    );

    return controller;
  }

  bool play({required String youtubeUrl, String? title}) {
    return _startPlayback(
      youtubeUrl: youtubeUrl,
      title: title,
      openFullscreen: true,
    );
  }

  bool prepareInline({required String youtubeUrl, String? title}) {
    return _startPlayback(
      youtubeUrl: youtubeUrl,
      title: title,
      openFullscreen: false,
    );
  }

  bool _startPlayback({
    required String youtubeUrl,
    String? title,
    required bool openFullscreen,
  }) {
    final videoId = extractYoutubeId(youtubeUrl);
    if (videoId == null || videoId.isEmpty) {
      return false;
    }

    _webViewController ??= _buildWebViewController();
    _hasPlaybackError = false;
    _playbackErrorMessage = '';

    final embedUri = _embedUriFor(videoId);
    _webViewController!.loadRequest(
      embedUri,
      headers: {'Referer': 'https://alikhbariah.com/'},
    );

    _title = title?.trim().isNotEmpty == true ? title!.trim() : '';
    _viewMode =
        openFullscreen
            ? InAppVideoViewMode.fullscreen
            : InAppVideoViewMode.hidden;
    notifyListeners();
    return true;
  }

  void minimize() {
    if (_webViewController == null) return;
    _viewMode = InAppVideoViewMode.mini;
    notifyListeners();
  }

  void showFullscreen() {
    if (_webViewController == null) return;
    _viewMode = InAppVideoViewMode.fullscreen;
    notifyListeners();
  }

  void close() {
    _webViewController?.loadHtmlString(
      '<html><body style="background:black;"></body></html>',
    );
    _title = '';
    _hasPlaybackError = false;
    _playbackErrorMessage = '';
    _viewMode = InAppVideoViewMode.hidden;
    notifyListeners();
  }
}
