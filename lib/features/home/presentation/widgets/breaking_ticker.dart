import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../../../../core/localization/l10n_extensions.dart';

class BreakingTicker extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textDirection = Directionality.of(context);
    const tickerVelocity = 30.0;
    if (titles.isEmpty) {
      return const SizedBox.shrink();
    }

    final cleanedTitles =
        titles.map((item) => item.trim()).where((item) => item.isNotEmpty);
    final fullText = cleanedTitles.join('   •   ');
    if (fullText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: borderRadius,
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
            child: ClipRect(
              child: Marquee(
                key: ValueKey(fullText),
                text: fullText,
                textDirection: textDirection,
                style: const TextStyle(
                  color: Color(0xFFC0392B),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                velocity: tickerVelocity,
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
        ],
      ),
    );
  }
}
