import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/localization/l10n_extensions.dart';

class BreakingTicker extends StatefulWidget {
  const BreakingTicker({
    super.key,
    required this.titles,
    this.margin = const EdgeInsets.fromLTRB(16, 12, 16, 4),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.height = 36,
  });

  final List<String> titles;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
  final double height;

  @override
  State<BreakingTicker> createState() => _BreakingTickerState();
}

class _BreakingTickerState extends State<BreakingTicker>
    with SingleTickerProviderStateMixin {
  static const TextStyle _titleStyle = TextStyle(
    color: Color(0xFFC0392B),
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );
  static const double _iconSize = 14;
  static const double _separatorStartGap = 10;
  static const double _separatorEndGap = 12;
  static const double _speedPxPerSecond = 30;
  static const double _minLoopWidth = 320;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartAnimation();
  }

  @override
  void didUpdateWidget(covariant BreakingTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.titles, widget.titles)) {
      _restartAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pauseTicker() {
    if (_controller.isAnimating) {
      _controller.stop(canceled: false);
    }
  }

  void _resumeTicker() {
    if (!_controller.isAnimating && widget.titles.isNotEmpty) {
      _controller.repeat();
    }
  }

  void _restartAnimation() {
    if (widget.titles.isEmpty) {
      _controller.stop();
      return;
    }

    final textDirection = Directionality.maybeOf(context) ?? TextDirection.rtl;
    final loopWidth = _segmentWidth(textDirection).clamp(_minLoopWidth, 5000);
    final seconds = (loopWidth / _speedPxPerSecond).clamp(8.0, 50.0);

    _controller
      ..stop()
      ..duration = Duration(milliseconds: (seconds * 1000).round())
      ..repeat();
  }

  double _separatorWidth() => _separatorStartGap + _iconSize + _separatorEndGap;

  double _measureTextWidth(String value, TextDirection textDirection) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: _titleStyle),
      maxLines: 1,
      textDirection: textDirection,
    )..layout();
    return painter.width;
  }

  double _segmentWidth(TextDirection textDirection) {
    if (widget.titles.isEmpty) {
      return _minLoopWidth;
    }

    double width = 0;
    for (var i = 0; i < widget.titles.length; i++) {
      width += _measureTextWidth(widget.titles[i], textDirection);
      if (i != widget.titles.length - 1) {
        width += _separatorWidth();
      }
    }

    // Add boundary separator between duplicated segments for seamless looping.
    return width + _separatorWidth();
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: _separatorStartGap,
        end: _separatorEndGap,
      ),
      child: Image.asset(
        'assets/images/icon.png',
        width: _iconSize,
        height: _iconSize,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Widget _buildTickerSegment(TextDirection textDirection) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: textDirection,
      children: [
        for (var i = 0; i < widget.titles.length; i++) ...[
          Text(
            widget.titles[i],
            style: _titleStyle,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            textDirection: textDirection,
          ),
          if (i != widget.titles.length - 1) _buildSeparator(),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textDirection = Directionality.of(context);
    final isRtl = textDirection == TextDirection.rtl;
    if (widget.titles.isEmpty) {
      return const SizedBox.shrink();
    }

    final loopWidth = _segmentWidth(textDirection);
    final tickerSegment = _buildTickerSegment(textDirection);

    return Container(
      width: double.infinity,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: widget.borderRadius,
        border: Border.all(color: const Color(0xFFF7CACA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Color(0xFFC0392B),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(7),
              ),
            ),
            height: double.infinity,
            alignment: Alignment.center,
            child: Row(
              children: [
                Icon(Icons.campaign_outlined, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  l10n.breakingNow,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => _pauseTicker(),
              onTapUp: (_) => _resumeTicker(),
              onTapCancel: _resumeTicker,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return OverflowBox(
                      minWidth: constraints.maxWidth,
                      maxWidth: double.infinity,
                      minHeight: constraints.maxHeight,
                      maxHeight: constraints.maxHeight,
                      alignment:
                          isRtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child: AnimatedBuilder(
                        animation: _controller,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: textDirection,
                          children: [
                            tickerSegment,
                            _buildSeparator(),
                            tickerSegment,
                          ],
                        ),
                        builder: (context, child) {
                          final offset = loopWidth * _controller.value;
                          final dx =
                              isRtl ? -offset : (offset - loopWidth);
                          return Transform.translate(
                            offset: Offset(dx, 0),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
