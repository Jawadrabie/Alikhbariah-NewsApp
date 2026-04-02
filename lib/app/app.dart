import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/localization/generated/app_localizations.dart';

import '../core/services/deep_link_service.dart';
import '../core/settings/app_settings_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/media/presentation/screens/in_app_video_player_screen.dart';

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  ThemeData _applyCairoIfNeeded(ThemeData base, bool enabled) {
    if (!enabled) {
      return base;
    }

    final textTheme = GoogleFonts.cairoTextTheme(base.textTheme);
    final primaryTextTheme = GoogleFonts.cairoTextTheme(base.primaryTextTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: primaryTextTheme,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettingsController.instance,
      builder: (context, _) {
        final locale = AppSettingsController.instance.locale;
        final isArabic = locale.languageCode.toLowerCase() == 'ar';
        final lightTheme = _applyCairoIfNeeded(AppTheme.light(), isArabic);
        final darkTheme = _applyCairoIfNeeded(AppTheme.dark(), isArabic);

        return MaterialApp(
          navigatorKey: DeepLinkService.navigatorKey,
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: AppSettingsController.instance.themeMode,
          locale: locale,
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
