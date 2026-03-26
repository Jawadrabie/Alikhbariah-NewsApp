import 'package:flutter/material.dart';

part 'dashboard_i18n_ar.dart';
part 'dashboard_i18n_en.dart';

class DashboardI18n {
  static const Map<String, Map<String, String>> _dict = {
    'en': _dashboardTranslationsEn,
    'ar': _dashboardTranslationsAr,
  };

  static String t(BuildContext context, String key) {
    final code = Localizations.localeOf(context).languageCode;
    final langMap = _dict[code] ?? _dict['en']!;
    return langMap[key] ?? key;
  }
}
