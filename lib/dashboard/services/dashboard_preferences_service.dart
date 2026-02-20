import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPreferencesService extends ChangeNotifier {
  DashboardPreferencesService._();

  static final DashboardPreferencesService instance =
      DashboardPreferencesService._();

  static const _themeModeKey = 'dashboard_theme_mode';
  static const _localeKey = 'dashboard_locale';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeValue = prefs.getString(_themeModeKey);
    _themeMode = _parseThemeMode(themeValue);

    final localeValue = prefs.getString(_localeKey);
    _locale = _parseLocale(localeValue);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Locale _parseLocale(String? value) {
    switch (value) {
      case 'en':
        return const Locale('en');
      case 'ar':
      default:
        return const Locale('ar');
    }
  }
}
