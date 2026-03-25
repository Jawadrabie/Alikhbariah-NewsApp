import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../controllers/in_app_video_controller.dart';
import '../../data/repositories/media_repository.dart';

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
                  Material(
                    elevation: 2,
                    color: Theme.of(context).colorScheme.surface,
                    shadowColor: Colors.black26,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (playerController != null)
                                _buildPlayer(playerController)
                              else
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
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
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.picture_in_picture_alt_rounded,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'عرض',
                                  onPressed: playerState.minimize,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 34,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.open_in_full_rounded,
                                    color: Colors.white,
                                  ),
                                  tooltip: 'تكبير',
                                  onPressed: playerState.showFullscreen,
                                  constraints: const BoxConstraints(
                                    minWidth: 34,
                                    minHeight: 34,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
