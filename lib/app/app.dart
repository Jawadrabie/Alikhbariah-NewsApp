import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/localization/generated/app_localizations.dart';

import '../core/settings/app_settings_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/media/presentation/screens/in_app_video_player_screen.dart';

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettingsController.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: AppSettingsController.instance.themeMode,
          locale: AppSettingsController.instance.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Stack(
              children: [
                if (child != null) child,
                const InAppMiniPlayerOverlay(),
              ],
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}
