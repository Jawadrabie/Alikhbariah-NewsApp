import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

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

class _BreakingTickerState extends State<BreakingTicker> {
  bool _isPaused = false;

  void _setPaused(bool value) {
    if (_isPaused == value) return;
    setState(() => _isPaused = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode.toLowerCase() == 'ar';
    final textDirection = isArabic ? TextDirection.ltr : Directionality.of(context);

    if (widget.titles.isEmpty) {
      return const SizedBox.shrink();
    }

    final cleanedTitles = widget.titles
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);
    final fullText = cleanedTitles.join('   •   ');
    if (fullText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: widget.borderRadius,
        border: Border.all(color: const Color(0xFFF7CACA)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPaused(true),
        onTapUp: (_) => _setPaused(false),
        onTapCancel: () => _setPaused(false),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFC0392B),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(7),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.breakingNow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRect(
                child: TickerMode(
                  enabled: !_isPaused,
                  child: Marquee(
                    key: ValueKey(fullText),
                    text: fullText,
                    textDirection: textDirection,
                    style: const TextStyle(
                      color: Color(0xFFC0392B),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    velocity: 30.0,
                    blankSpace: 20,
                    startPadding: 0,
                    accelerationCurve: Curves.linear,
                    decelerationCurve: Curves.linear,
                    accelerationDuration: Duration.zero,
                    decelerationDuration: Duration.zero,
                    pauseAfterRound: Duration.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
