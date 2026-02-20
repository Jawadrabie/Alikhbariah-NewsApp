import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/app_setting.dart';
import 'package:newsappjs/dashboard/services/dashboard_preferences_service.dart';
import 'package:newsappjs/dashboard/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _service = SettingsService();
  late Future<List<AppSetting>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getSettings();
    });
  }

  Future<void> _openForm({AppSetting? current}) async {
    String t(String key) => DashboardI18n.t(context, key);
    final keyController = TextEditingController(text: current?.key ?? '');
    final valueController = TextEditingController(text: current?.value ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? t('add_setting') : t('edit_setting')),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyController,
                  enabled: current == null,
                  decoration: InputDecoration(labelText: t('key')),
                ),
                TextField(
                  controller: valueController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: t('value')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final item = AppSetting(
                  key: keyController.text.trim(),
                  value: valueController.text,
                );
                await _service.upsertSetting(item);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _reload();
              },
              child: Text(t('save')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete(String key) async {
    await _service.deleteSetting(key);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = DashboardPreferencesService.instance;
    String t(String key) => DashboardI18n.t(context, key);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('settings')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: FutureBuilder<List<AppSetting>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${t('error')}: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('appearance_and_language'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<ThemeMode>(
                        value: prefs.themeMode,
                        decoration: InputDecoration(labelText: t('theme')),
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: prefs.locale.languageCode,
                        decoration: InputDecoration(labelText: t('language')),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Center(child: Text(t('no_settings')))
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(t('key'))),
                      DataColumn(label: Text(t('value'))),
                      DataColumn(label: Text(t('actions'))),
                    ],
                    rows: items
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(Text(item.key)),
                              DataCell(SizedBox(width: 480, child: Text(item.value))),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _openForm(current: item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _delete(item.key),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
