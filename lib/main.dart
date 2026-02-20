import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newsappjs/dashboard/router.dart';
import 'package:newsappjs/dashboard/services/dashboard_preferences_service.dart';
import 'package:newsappjs/core/services/push_notification_service.dart';
import 'package:newsappjs/core/settings/app_settings_controller.dart';

import 'app/app.dart';
import 'core/config/app_env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (AppEnv.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );
  }

  await PushNotificationService.initialize();
  await DashboardPreferencesService.instance.load();
  await AppSettingsController.instance.load();

  if (kIsWeb) {
    runApp(const DashboardApp());
  } else {
    runApp(const NewsApp());
  }
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DashboardPreferencesService.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Alikhbariah Dashboard',
          locale: DashboardPreferencesService.instance.locale,
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: DashboardPreferencesService.instance.themeMode,
          theme: ThemeData(
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.light,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.blue,
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
          ),
          routerConfig: DashboardRouter.router,
        );
      },
    );
  }
}
