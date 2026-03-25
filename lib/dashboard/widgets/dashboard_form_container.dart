import 'package:flutter/material.dart';

class DashboardFormContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final bool center;
  final EdgeInsetsGeometry padding;

  const DashboardFormContainer({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.center = true,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget content = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );

    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }

    if (center) {
      return Center(child: content);
    }

    return content;
  }
}
