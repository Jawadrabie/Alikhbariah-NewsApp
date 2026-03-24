import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/services/storage_service.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class CategoriesScreen extends StatefulWidget {
  final bool autoOpenCreateForm;
  final String? presetCategoryType;

  const CategoriesScreen({
    super.key,
    this.autoOpenCreateForm = false,
    this.presetCategoryType,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _service = CategoryService();
  final StorageService _storageService = StorageService();
  late Future<List<Category>> _future;
  bool _didTriggerAutoOpen = false;

  String _normalizeCategoryType(String? type) {
    switch ((type ?? '').trim().toLowerCase()) {
      case 'video':
        return 'video';
      case 'program':
        return 'program';
      case 'news':
      default:
        return 'news';
    }
  }

  int _nextOrderIndexForType(List<Category> categories, String type) {
    final matching = categories.where((item) => item.type == type).toList();
    if (matching.isEmpty) return 1;
    final maxOrder = matching
        .map((item) => item.orderIndex)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _loadData();
    });
  }

  Future<List<Category>> _loadData() async {
    return _service.getCategories();
  }

  Future<void> _openForm({
    Category? current,
    required List<Category> categories,
    String? presetType,
  }) async {
    String t(String key) => DashboardI18n.t(context, key);
    final nameController = TextEditingController(text: current?.name ?? '');
    final nameEnController = TextEditingController(text: current?.nameEn ?? '');
    final initialType = current?.type ?? _normalizeCategoryType(presetType);
    final orderController =
        TextEditingController(
          text: (current?.orderIndex ?? _nextOrderIndexForType(categories, initialType))
              .toString(),
        );
    String selectedType = initialType;
    String? coverImageUrl = current?.coverImageUrl;
    String? coverUploadError;
    bool uploadingCover = false;

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
                    CustomTextField(
                      controller: nameController,
                      labelText: t('name_ar'),
                    ),
                    CustomTextField(
                      controller: nameEnController,
                      labelText: t('name_en'),
                    ),
                    CustomDropdownField<String>(
                      value: selectedType,
                      labelText: t('category_type'),
                      items: [
                        DropdownMenuItem(
                          value: 'news',
                          child: Text(t('category_type_news')),
                        ),
                        DropdownMenuItem(
                          value: 'video',
                          child: Text(t('category_type_video')),
                        ),
                        DropdownMenuItem(
                          value: 'program',
                          child: Text(t('category_type_program')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setLocalState(() {
                          selectedType = value;
                          if (current == null) {
                            orderController.text =
                                _nextOrderIndexForType(categories, selectedType)
                                    .toString();
                          }
                        });
                      },
                    ),
                    if (selectedType == 'video' || selectedType == 'program') ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: uploadingCover
                                ? null
                                : () async {
                                    setLocalState(() {
                                      uploadingCover = true;
                                      coverUploadError = null;
                                    });

                                    try {
                                      final url = await _storageService.pickAndUploadImage(
                                        bucketName: 'news-images',
                                        folder: 'category-covers',
                                      );
                                      if (!context.mounted) return;
                                      setLocalState(() {
                                        if (url != null && url.isNotEmpty) {
                                          coverImageUrl = url;
                                        }
                                        uploadingCover = false;
                                      });
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      setLocalState(() {
                                        uploadingCover = false;
                                        if (e.toString().contains('file_too_large')) {
                                          coverUploadError = t('image_too_large');
                                        } else {
                                          coverUploadError = t('image_upload_failed');
                                        }
                                      });
                                    }
                                  },
                            icon: uploadingCover
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.image_outlined),
                            label: Text(t('upload_cover_image')),
                          ),
                          const SizedBox(width: 8),
                          if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                            IconButton(
                              tooltip: t('delete'),
                              onPressed: () {
                                setLocalState(() => coverImageUrl = null);
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                        ],
                      ),
                      if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                        CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(text: coverImageUrl),
                          labelText: t('uploaded_image_url'),
                        ),
                      if (coverUploadError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              coverUploadError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                    ],
                    CustomTextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      labelText: t('order_index'),
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
                if ((selectedType == 'video' || selectedType == 'program') &&
                    (coverImageUrl == null || coverImageUrl!.trim().isEmpty)) {
                  await DashboardDialogs.showError(
                    dialogContext,
                    t('please_upload_cover_image'),
                  );
                  return;
                }

                final item = Category(
                  id: current?.id ?? '',
                  name: nameController.text.trim(),
                  nameEn: nameEnController.text.trim(),
                  slug: current?.slug,
                  coverImageUrl: coverImageUrl,
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
            final newsCategories = items.where((item) => item.type == 'news').toList();
            final videoCategories = items.where((item) => item.type == 'video').toList();
            final programCategories = items.where((item) => item.type == 'program').toList();
            

            if (!_didTriggerAutoOpen && widget.autoOpenCreateForm) {
              _didTriggerAutoOpen = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _openForm(
                  categories: items,
                  presetType: widget.presetCategoryType,
                );
              });
            }

          return DashboardSectionView(
            title: t('categories'),
            actions: [
              FilledButton.icon(
                onPressed: () => _openForm(categories: items),
                icon: const Icon(Icons.add),
                label: Text(t('add_category')),
              ),
            ],
                child: newsCategories.isEmpty &&
                  videoCategories.isEmpty &&
                  programCategories.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.category_outlined,
                    title: t('no_categories_found'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('news_categories'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildCategoriesTable(
                        context: context,
                        categories: newsCategories,
                        scheme: scheme,
                        t: t,
                        showManageVideosAction: false,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t('video_categories'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildCategoriesTable(
                        context: context,
                        categories: videoCategories,
                        scheme: scheme,
                        t: t,
                        showManageVideosAction: true,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t('program_categories'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildCategoriesTable(
                        context: context,
                        categories: programCategories,
                        scheme: scheme,
                        t: t,
                        showManageVideosAction: true,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesTable({
    required BuildContext context,
    required List<Category> categories,
    required ColorScheme scheme,
    required String Function(String) t,
    required bool showManageVideosAction,
  }) {
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(t('no_categories_found')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        columns: [
          DataColumn(label: Text(t('name_ar'))),
          DataColumn(label: Text(t('name_en'))),
          DataColumn(label: Text(t('order'))),
          DataColumn(label: Text(t('actions'))),
        ],
        rows: categories
            .map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(item.name)),
                  DataCell(Text(item.nameEn)),
                  DataCell(Text(item.orderIndex.toString())),
                  DataCell(
                    Row(
                      children: [
                        if (showManageVideosAction)
                          IconButton(
                            icon: Icon(Icons.video_library, color: scheme.secondary),
                            tooltip: t('manage_category_videos'),
                            onPressed: () {
                              context.push(
                                '/dashboard/videos',
                                extra: {
                                  'categoryId': item.id,
                                  'categoryName': item.name,
                                },
                              );
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.edit, color: scheme.primary),
                          onPressed: () => _openForm(
                            current: item,
                            categories: categories,
                          ),
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
    );
  }

}
