part of 'categories_screen.dart';

extension _CategoriesScreenView on _CategoriesScreenState {
  Widget _buildScreen(BuildContext context) {
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
          final newsCategories =
              items.where((item) => item.type == 'news').toList();
          final videoCategories =
              items.where((item) => item.type == 'video').toList();
          final programCategories =
              items.where((item) => item.type == 'program').toList();

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
            child:
                newsCategories.isEmpty &&
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

    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(
              scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            dataRowMaxHeight: 60,
            columns: [
              DataColumn(
                label: Text(
                  t('name_ar'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  t('name_en'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  t('order'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  t('actions'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows:
                categories.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(Text(item.nameEn)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.orderIndex.toString(),
                            style: TextStyle(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showManageVideosAction)
                              IconButton(
                                icon: Icon(
                                  Icons.video_library_rounded,
                                  color: scheme.secondary,
                                ),
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
                              icon: Icon(
                                Icons.edit_rounded,
                                color: scheme.primary,
                              ),
                              tooltip: t('edit'),
                              onPressed:
                                  () => _openForm(
                                    current: item,
                                    categories: categories,
                                  ),
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
    );
  }
}
