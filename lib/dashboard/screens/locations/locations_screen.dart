import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/location.dart';
import 'package:newsappjs/dashboard/services/location_service.dart';
import 'package:newsappjs/dashboard/widgets/dashboard_button_content.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final LocationService _service = LocationService();
  late Future<List<Location>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getLocations();
    });
  }

  Future<void> _openForm({Location? current}) async {
    String t(String key) => DashboardI18n.t(context, key);
    final nameController = TextEditingController(text: current?.name ?? '');
    final nameEnController = TextEditingController(text: current?.nameEn ?? '');
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(
                current == null ? t('add_location') : t('edit_location'),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: nameController,
                      labelText: t('name'),
                    ),
                    CustomTextField(
                      controller: nameEnController,
                      labelText: t('name_en'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(t('cancel')),
                ),
                FilledButton(
                  onPressed:
                      isSaving
                          ? null
                          : () async {
                            setLocalState(() => isSaving = true);
                            final item = Location(
                              id: current?.id ?? '',
                              name: nameController.text.trim(),
                              nameEn:
                                  nameEnController.text.trim().isEmpty
                                      ? null
                                      : nameEnController.text.trim(),
                              slug: current?.slug,
                            );

                            try {
                              if (current == null) {
                                await _service.createLocation(item);
                              } else {
                                await _service.updateLocation(item);
                              }
                            } catch (e) {
                              if (!dialogContext.mounted) return;
                              setLocalState(() => isSaving = false);
                              await DashboardDialogs.showError(
                                dialogContext,
                                '${t('error_saving_location')}: $e',
                              );
                              return;
                            }

                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            _reload();
                          },
                  child: DashboardLoadingButtonChild(
                    isLoading: isSaving,
                    label: t('save'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _delete(String id) async {
    try {
      await _service.deleteLocation(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_location')}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<List<Location>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${t('error')}: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          return DashboardSectionView(
            title: t('locations'),
            actions: [
              FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: Text(t('add_location')),
              ),
            ],
            child:
                items.isEmpty
                    ? DashboardEmptyState(
                      icon: Icons.location_on_outlined,
                      title: t('no_locations_found'),
                    )
                    : Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Card(
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: scheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStatePropertyAll(
                              scheme.surfaceContainerHighest.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            dataRowMaxHeight: 60,
                            columns: [
                              DataColumn(
                                label: Text(
                                  t('name'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  t('name_en'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  t('actions'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows:
                                items.map((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_on_rounded,
                                              size: 18,
                                              color: scheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(item.nameEn ?? t('na'))),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit_rounded,
                                                color: scheme.primary,
                                              ),
                                              tooltip: t('edit'),
                                              onPressed:
                                                  () =>
                                                      _openForm(current: item),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_rounded,
                                                color: scheme.error,
                                              ),
                                              tooltip: t('delete'),
                                              onPressed: () => _delete(item.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }
}
