import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/screens/home_screen.dart';

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الإخبارية السورية',
      theme: AppTheme.light(),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}
