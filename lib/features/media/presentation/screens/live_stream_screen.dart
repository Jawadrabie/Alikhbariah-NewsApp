import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
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

  Future<void> _shareLive(String title, String url) async {
    await SharePlus.instance.share(
      ShareParams(
        text: '$title\n\n$url',
      ),
    );
  }

  Future<void> _openInlineLive({required String url, required String title}) async {
    final l10n = context.l10n;
    final didStart = InAppVideoController.instance.prepareInline(
      youtubeUrl: url,
      title: title,
    );

    if (!didStart) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedOpenLiveLink)),
      );
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
        future: _repository.getActiveLiveStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(l10n.failedLoadLiveStream(snapshot.error.toString())));
          }

          final stream = snapshot.data;
          if (stream == null || stream.youtubeUrl.isEmpty) {
            return Center(child: Text(l10n.noLiveNow));
          }

          final title = stream.broadcastTitle?.isNotEmpty == true
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
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.share_rounded),
                          onSelected: (value) async {
                            if (value == 'share') {
                              await _shareLive(title, stream.youtubeUrl);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem<String>(
                              value: 'share',
                              child: Text('مشاركة البث'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AspectRatio(
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
                        Positioned(
                          top: 8,
                          left: 8,
                          child: IconButton(
                            icon: const Icon(Icons.picture_in_picture_alt_rounded),
                            color: Colors.white,
                            onPressed: playerState.minimize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      stream.fallbackMessage?.isNotEmpty == true
                          ? stream.fallbackMessage!
                          : l10n.defaultLiveMessage,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
