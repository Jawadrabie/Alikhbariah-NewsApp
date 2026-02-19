import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class BreakingTicker extends StatelessWidget {
  const BreakingTicker({super.key, required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    if (titles.isEmpty) {
      return const SizedBox.shrink();
    }

    final String fullText = titles.join('  •  ');

    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF7CACA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFC0392B),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(7)), // Match container
            ),
            height: double.infinity,
            alignment: Alignment.center,
            child: const Row(
              children: [
                Icon(Icons.campaign_outlined, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'عاجل',
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
            child: Marquee(
              text: fullText,
              style: const TextStyle(
                color: Color(0xFFC0392B),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 50.0,
              velocity: 30.0,
              startPadding: 10.0,
              textDirection: TextDirection.rtl, // Content is Arabic
            ),
          ),
        ],
      ),
    );
  }
}
