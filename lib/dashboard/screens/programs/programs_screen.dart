import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/program.dart';
import 'package:newsappjs/dashboard/services/programs_service.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final ProgramsService _service = ProgramsService();
  late Future<List<Program>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getPrograms();
    });
  }

  Future<void> _openForm({Program? current}) async {
    String t(String key) => DashboardI18n.t(context, key);
    final nameController = TextEditingController(text: current?.name ?? '');
    final descriptionController =
        TextEditingController(text: current?.description ?? '');
    final imageController = TextEditingController(text: current?.imageUrl ?? '');
    final orderController =
        TextEditingController(text: (current?.orderIndex ?? 0).toString());
    bool isActive = current?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? t('add_program') : t('edit_program')),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: t('name')),
                    ),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(labelText: t('description')),
                    ),
                    TextField(
                      controller: imageController,
                      decoration: InputDecoration(labelText: t('image_url')),
                    ),
                    TextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: t('order_index')),
                    ),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (value) => setLocalState(() => isActive = value),
                      contentPadding: EdgeInsets.zero,
                      title: Text(t('active')),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                final item = Program(
                  id: current?.id ?? '',
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  imageUrl: imageController.text.trim().isEmpty
                      ? null
                      : imageController.text.trim(),
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  isActive: isActive,
                  createdAt: current?.createdAt ?? DateTime.now(),
                );

                try {
                  if (current == null) {
                    await _service.createProgram(item);
                  } else {
                    await _service.updateProgram(item);
                  }
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  await DashboardDialogs.showError(
                    dialogContext,
                    '${t('error_saving_program')}: $e',
                  );
                  return;
                }

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

  Future<void> _delete(String id) async {
    try {
      await _service.deleteProgram(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_program')}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<List<Program>>(
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
            title: t('programs'),
            actions: [
              FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: Text(t('add_program')),
              ),
            ],
            child: items.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.video_collection_outlined,
                    title: t('no_programs_found'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      columns: [
                        DataColumn(label: Text(t('name'))),
                        DataColumn(label: Text(t('order'))),
                        DataColumn(label: Text(t('active'))),
                        DataColumn(label: Text(t('actions'))),
                      ],
                      rows: items
                          .map(
                            (item) => DataRow(
                              cells: [
                                DataCell(Text(item.name)),
                                DataCell(Text(item.orderIndex.toString())),
                                DataCell(Text(item.isActive ? t('yes') : t('no'))),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.video_collection, color: scheme.secondary),
                                        tooltip: t('manage_episodes'),
                                        onPressed: () {
                                          context.push(
                                            '/dashboard/videos',
                                            extra: {
                                              'programId': item.id,
                                              'programName': item.name,
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: scheme.primary),
                                        onPressed: () => _openForm(current: item),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: scheme.error),
                                        onPressed: () => _delete(item.id),
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
          );
        },
      ),
    );
  }
}
