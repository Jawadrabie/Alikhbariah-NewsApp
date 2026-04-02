import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/widgets/sidebar.dart';

class DashboardScreen extends StatelessWidget {
  final Widget child;
  const DashboardScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: scheme.surface,
              surfaceTintColor: Colors.transparent,
            ),
            drawer: const Drawer(
              child: SafeArea(child: Sidebar()),
            ),
            body: Container(
              color: scheme.surfaceContainerLowest,
              child: child,
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              const Sidebar(),
              Expanded(
                child: Container(
                  color: scheme.surfaceContainerLowest,
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
