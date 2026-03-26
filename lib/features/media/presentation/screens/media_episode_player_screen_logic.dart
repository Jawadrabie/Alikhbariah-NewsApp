// ignore_for_file: invalid_use_of_protected_member

part of 'media_episode_player_screen.dart';

extension _MediaEpisodePlayerScreenLogic on _MediaEpisodePlayerScreenState {
  bool get _supportsLandscapeFullscreen =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  void _restorePortraitMode() {
    if (!_supportsLandscapeFullscreen) return;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  String _episodesLabel(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'en' ? 'Episodes' : 'الحلقات';
  }

  WebViewController _buildWebViewController() {
    final controller =
        WebViewController()
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
                final path = uri.path.toLowerCase();
                final isYoutubeHost =
                    host.contains('youtube.com') ||
                    host.contains('youtube-nocookie.com') ||
                    host.contains('youtu.be') ||
                    host.contains('googlevideo.com');
                final isYoutubeWatchLikePage =
                    (host.contains('youtube.com') ||
                        host.contains('youtube-nocookie.com')) &&
                    (path == '/watch' ||
                        path.startsWith('/shorts/') ||
                        path.startsWith('/live/') ||
                        path.startsWith('/channel/') ||
                        path.startsWith('/@'));
                final isGoogleAuth =
                    host.contains('accounts.google.com') ||
                    host.contains('google.com');
                if (isYoutubeWatchLikePage) {
                  return NavigationDecision.prevent;
                }
                return (isYoutubeHost || isGoogleAuth)
                    ? NavigationDecision.navigate
                    : NavigationDecision.prevent;
              },
              onWebResourceError: (error) {
                if (error.isForMainFrame == true) {
                  setState(() {
                    _playbackError = 'تعذر تشغيل الفيديو حاليا';
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
    return Uri.https('www.youtube-nocookie.com', '/embed/$videoId', const {
      'autoplay': '1',
      'playsinline': '1',
      'rel': '0',
      'modestbranding': '1',
      'controls': '0',
      'fs': '0',
      'disablekb': '1',
      'iv_load_policy': '3',
      'cc_load_policy': '0',
      'enablejsapi': '1',
    });
  }

  void _loadCurrentEpisode() {
    final id = InAppVideoController.extractYoutubeId(
      _currentEpisode.youtubeUrl,
    );
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

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.black38,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          iconSize: 18,
          icon: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  void _minimizeToFloatingPlayer() {
    final didStart = InAppVideoController.instance.prepareInline(
      youtubeUrl: _currentEpisode.youtubeUrl,
      title: _currentEpisode.title,
    );
    if (!didStart) return;

    InAppVideoController.instance.minimize();
    _restorePortraitMode();
    setState(() {
      _isExpandedPlayer = false;
      _isInlinePlayerMinimized = true;
    });
  }

  Widget _buildOverlayControls() {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.fit_screen_rounded,
            onPressed: () {
              if (_isExpandedPlayer) return;
              setState(() {
                _isExpandedPlayer = true;
                _isInlinePlayerMinimized = false;
              });
              if (_supportsLandscapeFullscreen) {
                SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.immersiveSticky,
                );
                SystemChrome.setPreferredOrientations(const [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
              }
            },
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            icon: Icons.picture_in_picture_alt_rounded,
            onPressed: () {
              _minimizeToFloatingPlayer();
            },
          ),
        ],
      ),
    );
  }
}
