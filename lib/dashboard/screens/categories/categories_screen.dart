import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _service = CategoryService();
  late Future<List<Category>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getCategories();
    });
  }

  Future<void> _openForm({Category? current}) async {
    String t(String key) => DashboardI18n.t(context, key);
    final nameController = TextEditingController(text: current?.name ?? '');
    final slugController = TextEditingController(text: current?.slug ?? '');
    final orderController =
        TextEditingController(text: (current?.orderIndex ?? 0).toString());
    String selectedType = current?.type ?? 'news';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? t('add_category') : t('edit_category')),
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
                      controller: slugController,
                      decoration: InputDecoration(labelText: t('slug')),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(labelText: t('category_type')),
                      items: [
                        DropdownMenuItem(
                          value: 'news',
                          child: Text(t('category_type_news')),
                        ),
                        DropdownMenuItem(
                          value: 'video',
                          child: Text(t('category_type_video')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setLocalState(() => selectedType = value);
                      },
                    ),
                    TextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: t('order_index')),
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
                final item = Category(
                  id: current?.id ?? '',
                  name: nameController.text.trim(),
                  slug: slugController.text.trim().isEmpty
                      ? null
                      : slugController.text.trim(),
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  type: selectedType,
                );

                try {
                  if (current == null) {
                    await _service.createCategory(item);
                  } else {
                    await _service.updateCategory(item);
                  }
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  await DashboardDialogs.showError(
                    dialogContext,
                    '${t('error_saving_category')}: $e',
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
      await _service.deleteCategory(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_category')}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<List<Category>>(
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
            title: t('categories'),
            actions: [
              FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: Text(t('add_category')),
              ),
            ],
            child: items.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.category_outlined,
                    title: t('no_categories_found'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      columns: [
                        DataColumn(label: Text(t('name'))),
                        DataColumn(label: Text(t('slug'))),
                        DataColumn(label: Text(t('category_type'))),
                        DataColumn(label: Text(t('order'))),
                        DataColumn(label: Text(t('actions'))),
                      ],
                      rows: items
                          .map(
                            (item) => DataRow(
                              cells: [
                                DataCell(Text(item.name)),
                                DataCell(Text(item.slug ?? t('na'))),
                                DataCell(
                                  Text(
                                    item.type == 'video'
                                        ? t('category_type_video')
                                        : t('category_type_news'),
                                  ),
                                ),
                                DataCell(Text(item.orderIndex.toString())),
                                DataCell(
                                  Row(
                                    children: [
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
