part of 'videos_screen.dart';

extension _VideosScreenView on _VideosScreenState {
  Widget _buildScreen(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;
    final isScoped = widget.categoryId != null || widget.programId != null;
    final title =
        widget.categoryName != null
            ? t(
              'category_videos',
            ).replaceAll('{name}', widget.categoryName ?? '')
            : widget.programName == null
            ? t('videos')
            : t(
              'program_episodes',
            ).replaceAll('{name}', widget.programName ?? '');

    if (!isScoped) {
      return Scaffold(
        body: FutureBuilder<List<Category>>(
          future: _categoriesWithCountsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('${t('error')}: ${snapshot.error}'));
            }

            final categories = snapshot.data ?? [];
            return DashboardSectionView(
              title: t('videos'),
              actions: [
                FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add),
                  label: Text(t('add_video')),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    context.push(
                      '/dashboard/categories',
                      extra: {
                        'autoOpenCreateForm': true,
                        'presetCategoryType': 'video',
                      },
                    );
                  },
                  icon: const Icon(Icons.playlist_add),
                  label: Text(t('add_new_video_list')),
                ),
              ],
              child:
                  categories.isEmpty
                      ? DashboardEmptyState(
                        icon: Icons.video_collection_outlined,
                        title: t('no_categories_found'),
                      )
                      : Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Card(
                            elevation: 0,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: scheme.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
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
                                      t('name_ar'),
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
                                      t('order'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      t('views'),
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
                                    categories
                                        .map(
                                          (item) => DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  item.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              DataCell(Text(item.nameEn)),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        scheme.primaryContainer,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    item.orderIndex.toString(),
                                                    style: TextStyle(
                                                      color:
                                                          scheme
                                                              .onPrimaryContainer,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  item.videoCount.toString(),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.open_in_new_rounded,
                                                        color: scheme.secondary,
                                                      ),
                                                      tooltip: t(
                                                        'manage_category_videos',
                                                      ),
                                                      onPressed: () {
                                                        context.push(
                                                          '/dashboard/videos',
                                                          extra: {
                                                            'categoryId':
                                                                item.id,
                                                            'categoryName':
                                                                item.name,
                                                          },
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.edit_rounded,
                                                        color: scheme.primary,
                                                      ),
                                                      tooltip: t(
                                                        'edit_category',
                                                      ),
                                                      onPressed:
                                                          () => _openCategoryForm(
                                                            current: item,
                                                          ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.delete_rounded,
                                                        color: scheme.error,
                                                      ),
                                                      tooltip: t('delete'),
                                                      onPressed:
                                                          () => _deleteCategory(
                                                            item.id,
                                                          ),
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
                          ),
                        ),
            );
          },
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder<List<VideoItem>>(
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
            title: title,
            actions: [
              FilledButton.icon(
                onPressed:
                    () => _openForm(
                      scopedItems: items,
                      defaultCategoryType: 'video',
                    ),
                icon: const Icon(Icons.add),
                label: Text(t('add_news_video')),
              ),
            ],
            child:
                items.isEmpty
                    ? DashboardEmptyState(
                      icon: Icons.ondemand_video_outlined,
                      title: t('no_videos_found'),
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
                                  t('title_ar'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  t('title_en'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  t('youtube_url'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  t('order'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  t('hidden'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  t('published_at'),
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
                                items
                                    .map(
                                      (item) => DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(item.titleEn)),
                                          DataCell(Text(item.youtubeUrl)),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: scheme.primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                item.orderIndex.toString(),
                                                style: TextStyle(
                                                  color:
                                                      scheme.onPrimaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              item.isHidden ? t('yes') : t('no'),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              item.publishedAt?.toString() ??
                                                  t('na'),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit_rounded,
                                                    color: scheme.primary,
                                                  ),
                                                  onPressed:
                                                      () => _openForm(
                                                        current: item,
                                                        scopedItems: items,
                                                      ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete_rounded,
                                                    color: scheme.error,
                                                  ),
                                                  onPressed:
                                                      () => _delete(item.id),
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
                      ),
                    ),
          );
        },
      ),
    );
  }
}
