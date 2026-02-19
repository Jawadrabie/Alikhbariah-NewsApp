import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/widgets/sidebar.dart';

class DashboardScreen extends StatelessWidget {
  final Widget child;
  const DashboardScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
