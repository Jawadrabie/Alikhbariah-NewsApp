import 'package:flutter/material.dart';

class DashboardLoadingButtonChild extends StatelessWidget {
  const DashboardLoadingButtonChild({
    super.key,
    required this.isLoading,
    required this.label,
    this.loadingLabel,
    this.spinnerSize = 14,
  });

  final bool isLoading;
  final String label;
  final String? loadingLabel;
  final double spinnerSize;

  @override
  Widget build(BuildContext context) {
    final displayedLabel = isLoading ? (loadingLabel ?? '$label...') : label;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: spinnerSize,
            height: spinnerSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
        ],
        Text(displayedLabel),
      ],
    );
  }
}
