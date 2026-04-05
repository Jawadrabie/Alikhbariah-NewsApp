import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newsappjs/dashboard/router.dart';
import 'package:newsappjs/dashboard/services/dashboard_preferences_service.dart';
import 'package:newsappjs/core/services/local_cache_service.dart';
import 'package:newsappjs/core/services/push_notification_service.dart';
import 'package:newsappjs/core/settings/app_settings_controller.dart';
import 'package:newsappjs/core/theme/dashboard_theme.dart';

import 'app/app.dart';
import 'core/config/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await LocalCacheService.instance.init();

  if (AppEnv.hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: AppEnv.supabaseUrl,
        anonKey: AppEnv.supabaseAnonKey,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Supabase initialization timeout'),
      );
    } catch (error) {
      debugPrint('Supabase initialization failed (app will work offline): $error');
    }
  }

  await PushNotificationService.initialize();
  
  try {
    await DashboardPreferencesService.instance.load();
  } catch (error) {
    debugPrint('Dashboard preferences loading failed: $error');
  }
  
  try {
    await AppSettingsController.instance.load();
  } catch (error) {
    debugPrint('App settings loading failed: $error');
  }

  if (kIsWeb) {
    runApp(const DashboardApp());
  } else {
    runApp(const NewsApp());
  }
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

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
      animation: DashboardPreferencesService.instance,
      builder: (context, _) {
        final locale = DashboardPreferencesService.instance.locale;
        final isArabic = locale.languageCode.toLowerCase() == 'ar';
        final lightTheme = _applyCairoIfNeeded(DashboardTheme.light(), isArabic);
        final darkTheme = _applyCairoIfNeeded(DashboardTheme.dark(), isArabic);

        return MaterialApp.router(
          title: 'Alikhbariah Dashboard',
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: DashboardPreferencesService.instance.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          routerConfig: DashboardRouter.router,
        );
      },
    );
  }
}
