import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/services/dashboard_preferences_service.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = DashboardPreferencesService.instance;
    String t(String key) => DashboardI18n.t(context, key);

    return DashboardSectionView(
      title: t('settings'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                t('appearance_and_language'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomDropdownField<ThemeMode>(
                  value: prefs.themeMode,
                  labelText: t('theme'),
                  prefixIcon: const Icon(Icons.brightness_6_outlined),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(t('system')),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(t('light')),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(t('dark')),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      prefs.setThemeMode(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomDropdownField<String>(
                  value: prefs.locale.languageCode,
                  labelText: t('language'),
                  prefixIcon: const Icon(Icons.language_outlined),
                  items: [
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text(t('arabic')),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(t('english')),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      prefs.setLocale(Locale(value));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
