part of 'videos_screen.dart';

extension _VideosScreenView on _VideosScreenState {
  Widget _buildScreen(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final showArabic = localeCode == 'ar';
    final showEnglish = !showArabic;
    Widget cellText(
      String value, {
      required double width,
      FontWeight? weight,
    }) => SizedBox(
      width: width,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: weight == null ? null : TextStyle(fontWeight: weight),
      ),
    );
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const columnSpacing = 16.0;
                                const horizontalMargin = 12.0;
                                final maxWidth =
                                    constraints.maxWidth.isFinite
                                        ? constraints.maxWidth
                                        : MediaQuery.sizeOf(context).width;
                                final available =
                                    maxWidth -
                                    (horizontalMargin * 2) -
                                    (columnSpacing * 3);
                                final actionsWidth =
                                    (available * 0.2)
                                        .clamp(120.0, 160.0)
                                        .toDouble();
                                final orderWidth =
                                    (available * 0.12)
                                        .clamp(60.0, 80.0)
                                        .toDouble();
                                final viewsWidth =
                                    (available * 0.12)
                                        .clamp(70.0, 90.0)
                                        .toDouble();
                                final nameWidth =
                                    available -
                                    actionsWidth -
                                    orderWidth -
                                    viewsWidth;
                                final resolvedNameWidth =
                                    nameWidth.isFinite && nameWidth > 160
                                        ? nameWidth
                                        : 160.0;
                                return DataTable(
                                  headingRowColor: WidgetStatePropertyAll(
                                    scheme.surfaceContainerHighest.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  dataRowMaxHeight: 60,
                                  columnSpacing: columnSpacing,
                                  horizontalMargin: horizontalMargin,
                                  columns: [
                                    if (showArabic)
                                      DataColumn(
                                        label: cellText(
                                          t('name_ar'),
                                          width: resolvedNameWidth,
                                          weight: FontWeight.bold,
                                        ),
                                      ),
                                    if (showEnglish)
                                      DataColumn(
                                        label: cellText(
                                          t('name_en'),
                                          width: resolvedNameWidth,
                                          weight: FontWeight.bold,
                                        ),
                                      ),
                                    DataColumn(
                                      label: cellText(
                                        t('order'),
                                        width: orderWidth,
                                        weight: FontWeight.bold,
                                      ),
                                    ),
                                    DataColumn(
                                      label: cellText(
                                        t('views'),
                                        width: viewsWidth,
                                        weight: FontWeight.bold,
                                      ),
                                    ),
                                    DataColumn(
                                      label: cellText(
                                        t('actions'),
                                        width: actionsWidth,
                                        weight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  rows:
                                      categories
                                          .map(
                                            (item) => DataRow(
                                              cells: [
                                                if (showArabic)
                                                  DataCell(
                                                    cellText(
                                                      item.name,
                                                      width: resolvedNameWidth,
                                                      weight: FontWeight.w600,
                                                    ),
                                                  ),
                                                if (showEnglish)
                                                  DataCell(
                                                    cellText(
                                                      item.nameEn,
                                                      width: resolvedNameWidth,
                                                    ),
                                                  ),
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
                                );
                              },
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
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const columnSpacing = 16.0;
                            const horizontalMargin = 12.0;
                            final maxWidth =
                                constraints.maxWidth.isFinite
                                    ? constraints.maxWidth
                                    : MediaQuery.sizeOf(context).width;
                            final available =
                                maxWidth -
                                (horizontalMargin * 2) -
                                (columnSpacing * 5);
                            final actionsWidth =
                                (available * 0.18)
                                    .clamp(120.0, 160.0)
                                    .toDouble();
                            final orderWidth =
                                (available * 0.08)
                                    .clamp(60.0, 80.0)
                                    .toDouble();
                            final hiddenWidth =
                                (available * 0.08)
                                    .clamp(60.0, 80.0)
                                    .toDouble();
                            final publishedWidth =
                                (available * 0.18)
                                    .clamp(130.0, 180.0)
                                    .toDouble();
                            final youtubeWidth =
                                (available * 0.22)
                                    .clamp(180.0, 260.0)
                                    .toDouble();
                            final titleWidth =
                                available -
                                actionsWidth -
                                orderWidth -
                                hiddenWidth -
                                publishedWidth -
                                youtubeWidth;
                            final resolvedTitleWidth =
                                titleWidth.isFinite && titleWidth > 220
                                    ? titleWidth
                                    : 220.0;
                            return DataTable(
                              headingRowColor: WidgetStatePropertyAll(
                                scheme.surfaceContainerHighest.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              dataRowMaxHeight: 60,
                              columnSpacing: columnSpacing,
                              horizontalMargin: horizontalMargin,
                              columns: [
                                if (showArabic)
                                  DataColumn(
                                    label: cellText(
                                      t('title_ar'),
                                      width: resolvedTitleWidth,
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                                if (showEnglish)
                                  DataColumn(
                                    label: cellText(
                                      t('title_en'),
                                      width: resolvedTitleWidth,
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                                DataColumn(
                                  label: cellText(
                                    t('youtube_url'),
                                    width: youtubeWidth,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                                DataColumn(
                                  label: cellText(
                                    t('order'),
                                    width: orderWidth,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                                DataColumn(
                                  label: cellText(
                                    t('hidden'),
                                    width: hiddenWidth,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                                DataColumn(
                                  label: cellText(
                                    t('published_at'),
                                    width: publishedWidth,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                                DataColumn(
                                  label: cellText(
                                    t('actions'),
                                    width: actionsWidth,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              rows:
                                  items
                                      .map(
                                        (item) => DataRow(
                                          cells: [
                                            if (showArabic)
                                              DataCell(
                                                cellText(
                                                  item.title,
                                                  width: resolvedTitleWidth,
                                                  weight: FontWeight.w600,
                                                ),
                                              ),
                                            if (showEnglish)
                                              DataCell(
                                                cellText(
                                                  item.titleEn,
                                                  width: resolvedTitleWidth,
                                                ),
                                              ),
                                            DataCell(
                                              cellText(
                                                item.youtubeUrl,
                                                width: youtubeWidth,
                                              ),
                                            ),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      scheme.primaryContainer,
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
                                                item.isHidden
                                                    ? t('yes')
                                                    : t('no'),
                                              ),
                                            ),
                                            DataCell(
                                              cellText(
                                                item.publishedAt?.toString() ??
                                                    t('na'),
                                                width: publishedWidth,
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
                            );
                          },
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }
}
