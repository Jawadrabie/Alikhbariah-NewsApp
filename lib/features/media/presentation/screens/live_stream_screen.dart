import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../data/repositories/media_repository.dart';
import '../controllers/in_app_video_controller.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final MediaRepository _repository = MediaRepository();
  String? _autoStartedUrl;
  String _currentLanguageCode = 'ar';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLanguageCode =
        Localizations.localeOf(context).languageCode.toLowerCase();
  }

  Future<void> _openInlineLive({
    required String url,
    required String title,
  }) async {
    final l10n = context.l10n;
    final didStart = InAppVideoController.instance.prepareInline(
      youtubeUrl: url,
      title: title,
    );

    if (!didStart) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.failedOpenLiveLink)));
      return;
    }

    _autoStartedUrl = url;
  }

  void _ensureAutoPlay({required String url, required String title}) {
    if (_autoStartedUrl == url) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openInlineLive(url: url, title: title);
    });
  }

  Widget _buildPlayer(WebViewController controller) {
    if (defaultTargetPlatform == TargetPlatform.android &&
        controller.platform is AndroidWebViewController) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: controller.platform as AndroidWebViewController,
          displayWithHybridComposition: !kDebugMode,
        ),
      );
    }

    return WebViewWidget(controller: controller);
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

  Widget _buildOverlayControls(InAppVideoController playerState) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.fit_screen_rounded,
            onPressed: playerState.showFullscreen,
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            icon: Icons.picture_in_picture_alt_rounded,
            onPressed: playerState.minimize,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.liveStream)),
      body: FutureBuilder(
        future: _repository.getActiveLiveStream(
          languageCode: _currentLanguageCode,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(l10n.failedLoadLiveStream(snapshot.error.toString())),
            );
          }

          final stream = snapshot.data;
          if (stream == null || stream.youtubeUrl.isEmpty) {
            return Center(child: Text(l10n.noLiveNow));
          }

          final title =
              stream.broadcastTitle?.isNotEmpty == true
                  ? stream.broadcastTitle!
                  : l10n.defaultLiveTitle;
          _ensureAutoPlay(url: stream.youtubeUrl, title: title);

          return AnimatedBuilder(
            animation: InAppVideoController.instance,
            builder: (context, _) {
              final playerState = InAppVideoController.instance;
              final playerController = playerState.webViewController;
              final isMiniMode =
                  playerState.viewMode == InAppVideoViewMode.mini;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            textDirection: Directionality.of(context),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!isMiniMode)
                    Material(
                      elevation: 2,
                      color: Theme.of(context).colorScheme.surface,
                      shadowColor: Colors.black26,
                      clipBehavior: Clip.antiAlias,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (playerController != null)
                              _buildPlayer(playerController)
                            else
                              const Center(child: CircularProgressIndicator()),
                            if (playerState.hasPlaybackError)
                              Container(
                                color: Colors.black54,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  playerState.playbackErrorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            _buildOverlayControls(playerState),
                          ],
                        ),
                      ),
                    ),
                  if (isMiniMode) const SizedBox(height: 4),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            stream.fallbackMessage?.isNotEmpty == true
                                ? stream.fallbackMessage!
                                : l10n.defaultLiveMessage,
                            textAlign: TextAlign.center,
                            textDirection: Directionality.of(context),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
