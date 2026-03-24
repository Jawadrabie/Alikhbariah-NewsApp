import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../controllers/in_app_video_controller.dart';
import '../../data/models/video_item_model.dart';

class MediaEpisodePlayerScreen extends StatefulWidget {
  const MediaEpisodePlayerScreen({
    super.key,
    required this.episodes,
    required this.initialIndex,
    required this.listTitle,
  });

  final List<VideoItemModel> episodes;
  final int initialIndex;
  final String listTitle;

  @override
  State<MediaEpisodePlayerScreen> createState() => _MediaEpisodePlayerScreenState();
}

class _MediaEpisodePlayerScreenState extends State<MediaEpisodePlayerScreen> {
  late int _currentIndex;
  late final WebViewController _webViewController;
  String? _playbackError;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.episodes.length - 1);
    _webViewController = _buildWebViewController();
    _loadCurrentEpisode();
  }

  VideoItemModel get _currentEpisode => widget.episodes[_currentIndex];

  String _episodesLabel(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'en' ? 'Episodes' : 'الحلقات';
  }

  WebViewController _buildWebViewController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme == 'about' || uri.scheme == 'data') {
              return NavigationDecision.navigate;
            }
            if (uri.scheme != 'http' && uri.scheme != 'https') {
              return NavigationDecision.prevent;
            }

            final host = uri.host.toLowerCase();
            final isYoutubeHost =
                host.contains('youtube.com') ||
                host.contains('youtube-nocookie.com') ||
                host.contains('youtu.be') ||
                host.contains('googlevideo.com');
            final isGoogleAuth =
                host.contains('accounts.google.com') || host.contains('google.com');
            return (isYoutubeHost || isGoogleAuth)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) {
              setState(() {
                _playbackError = 'تعذر تشغيل الفيديو حالياً';
              });
            }
          },
        ),
      );

    if (defaultTargetPlatform == TargetPlatform.android &&
        controller.platform is AndroidWebViewController) {
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

  Uri _embedUriFor(String videoId) {
    return Uri.parse(
      'https://www.youtube.com/embed/$videoId?autoplay=1&playsinline=1&rel=0&modestbranding=1&controls=1&fs=1&iv_load_policy=3',
    );
  }

  void _loadCurrentEpisode() {
    final id = InAppVideoController.extractYoutubeId(_currentEpisode.youtubeUrl);
    if (id == null || id.isEmpty) {
      setState(() {
        _playbackError = 'رابط الفيديو غير صالح';
      });
      return;
    }

    setState(() {
      _playbackError = null;
    });

    _webViewController.loadRequest(
      _embedUriFor(id),
      headers: const {'Referer': 'https://alikhbariah.com/'},
    );
  }

  String _thumbnailOf(VideoItemModel item) {
    if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
      return item.thumbnailUrl!;
    }
    final id = InAppVideoController.extractYoutubeId(item.youtubeUrl);
    if (id == null || id.isEmpty) {
      return '';
    }
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  Widget _buildPlayer() {
    if (defaultTargetPlatform == TargetPlatform.android &&
        _webViewController.platform is AndroidWebViewController) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: _webViewController.platform as AndroidWebViewController,
          displayWithHybridComposition: !kDebugMode,
        ),
      );
    }
    return WebViewWidget(controller: _webViewController);
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final localeName = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(widget.listTitle)),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: Colors.black, child: _buildPlayer()),
                if (_playbackError != null)
                  Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: Text(
                      _playbackError!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentEpisode.title,
                  textDirection: direction,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  _episodesLabel(context),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              itemCount: widget.episodes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = widget.episodes[index];
                final thumb = _thumbnailOf(item);
                final date = intl
                    .DateFormat('yyyy-MM-dd – HH:mm', localeName)
                    .format(item.publishedAt ?? item.createdAt);
                final selected = index == _currentIndex;

                return Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  color: selected
                      ? Theme.of(context).colorScheme.primary.withAlpha(18)
                      : null,
                  child: InkWell(
                    onTap: () {
                      if (_currentIndex == index) return;
                      setState(() {
                        _currentIndex = index;
                      });
                      _loadCurrentEpisode();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 124,
                              height: 78,
                              color: const Color(0xFFE5EBEF),
                              child: thumb.isEmpty
                                  ? const Icon(Icons.play_circle_fill_rounded)
                                  : Image.network(
                                      thumb,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.play_circle_fill_rounded),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_episodesLabel(context)} ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  textDirection: direction,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  date,
                                  textDirection: direction,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.play_circle_filled_rounded
                                : Icons.play_arrow_rounded,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}