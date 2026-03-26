import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../controllers/in_app_video_controller.dart';

class InAppMiniPlayerOverlay extends StatefulWidget {
  const InAppMiniPlayerOverlay({super.key});

  @override
  State<InAppMiniPlayerOverlay> createState() => _InAppMiniPlayerOverlayState();
}

class _InAppMiniPlayerOverlayState extends State<InAppMiniPlayerOverlay> {
  Offset? _dragOffset;

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

  Widget _buildOverlayControls({
    required VoidCallback onMinimize,
    required VoidCallback onExpand,
  }) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.fit_screen_rounded,
            onPressed: onExpand,
          ),
          const SizedBox(height: 4),
          _buildControlButton(
            icon: Icons.picture_in_picture_alt_rounded,
            onPressed: onMinimize,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mediaQuery = MediaQuery.of(context);
    final maxWidth = mediaQuery.size.width;
    final miniWidth = (maxWidth * 0.48).clamp(180.0, 240.0).toDouble();
    final miniHeight = miniWidth * 9 / 16;
    final bottomInset = 12 + mediaQuery.padding.bottom;
    final screenSize = mediaQuery.size;
    final minX = 12.0;
    final maxX = (screenSize.width - miniWidth - 12).clamp(
      12.0,
      screenSize.width,
    );
    final minY = 12.0 + mediaQuery.padding.top;
    final maxY = (screenSize.height - miniHeight - bottomInset).clamp(
      minY,
      screenSize.height,
    );

    return AnimatedBuilder(
      animation: InAppVideoController.instance,
      builder: (context, _) {
        final state = InAppVideoController.instance;
        final playerController = state.webViewController;
        if (state.viewMode == InAppVideoViewMode.hidden ||
            playerController == null) {
          return const SizedBox.shrink();
        }

        if (state.isFullscreenVisible) {
          return Positioned.fill(
            child: Material(
              color: Colors.black,
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.title.isNotEmpty
                                  ? state.title
                                  : l10n.videos,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                            onPressed: state.close,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildPlayer(playerController),
                            if (state.hasPlaybackError)
                              Container(
                                color: Colors.black54,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  state.playbackErrorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            _buildOverlayControls(
                              onMinimize: state.minimize,
                              onExpand: state.showFullscreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final defaultOffset = Offset(minX, maxY);
        final safeOffset = _dragOffset ?? defaultOffset;
        final clampedOffset = Offset(
          safeOffset.dx.clamp(minX, maxX),
          safeOffset.dy.clamp(minY, maxY),
        );

        return Positioned(
          left: clampedOffset.dx,
          top: clampedOffset.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                final next = (_dragOffset ?? defaultOffset) + details.delta;
                _dragOffset = Offset(
                  next.dx.clamp(minX, maxX),
                  next.dy.clamp(minY, maxY),
                );
              });
            },
            child: Material(
              elevation: 10,
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: miniWidth,
                height: miniHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildPlayer(playerController),
                    if (state.hasPlaybackError)
                      Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          state.playbackErrorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    _buildOverlayControls(
                      onMinimize: state.minimize,
                      onExpand: state.showFullscreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
