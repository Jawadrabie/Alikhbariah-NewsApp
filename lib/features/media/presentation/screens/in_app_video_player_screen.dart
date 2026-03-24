import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mediaQuery = MediaQuery.of(context);
    final maxWidth = mediaQuery.size.width;
    final miniWidth = maxWidth < 420 ? maxWidth - 24 : 300.0;
    final miniHeight = miniWidth * 9 / 16;
    final bottomInset = 12 + mediaQuery.padding.bottom;
    final screenSize = mediaQuery.size;
    final minX = 12.0;
    final maxX = (screenSize.width - miniWidth - 12).clamp(12.0, screenSize.width);
    final minY = 12.0 + mediaQuery.padding.top;
    final maxY = (screenSize.height - miniHeight - bottomInset)
        .clamp(minY, screenSize.height);

    return AnimatedBuilder(
      animation: InAppVideoController.instance,
      builder: (context, _) {
        final state = InAppVideoController.instance;
        final playerController = state.webViewController;
        if (state.viewMode == InAppVideoViewMode.hidden || playerController == null) {
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
                              state.title.isNotEmpty ? state.title : l10n.videos,
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
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
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
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: IconButton(
                                          icon: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white),
                                          tooltip: 'عرض',
                                          onPressed: state.minimize,
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
                                          icon: const Icon(Icons.open_in_full_rounded, color: Colors.white),
                                          tooltip: 'تكبير',
                                          onPressed: state.showFullscreen,
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
                              ),
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
                height: miniHeight + 52,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: SizedBox(
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
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                icon: const Icon(Icons.picture_in_picture_alt_rounded, color: Colors.white),
                                tooltip: 'عرض',
                                onPressed: state.minimize,
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
                                icon: const Icon(Icons.open_in_full_rounded, color: Colors.white),
                                tooltip: 'تكبير',
                                onPressed: state.showFullscreen,
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
