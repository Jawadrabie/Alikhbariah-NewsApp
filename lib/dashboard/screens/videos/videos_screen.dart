import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/models/video_item.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/services/videos_service.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';
import 'package:go_router/go_router.dart';

class VideosScreen extends StatefulWidget {
  final String? programId;
  final String? programName;
  final String? categoryId;
  final String? categoryName;
  final bool openAddForm;
  final String? defaultCategoryType;

  const VideosScreen({
    super.key,
    this.programId,
    this.programName,
    this.categoryId,
    this.categoryName,
    this.openAddForm = false,
    this.defaultCategoryType,
  });

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final VideosService _service = VideosService();
  final CategoryService _categoryService = CategoryService();
  late Future<List<VideoItem>> _future;
  String? _selectedCategoryId;
  bool _didAutoOpenAddForm = false;

  int _nextVideoOrderIndex(List<VideoItem> videos) {
    if (videos.isEmpty) return 1;
    final maxOrder = videos
        .map((item) => item.orderIndex)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  Future<int> _nextVideoOrderIndexForScope({
    String? programId,
    String? categoryId,
  }) async {
    final videos = await _service.getVideos(programId: programId, categoryId: categoryId);
    return _nextVideoOrderIndex(videos);
  }
  
  Future<List<Category>> _loadCategoriesWithCounts() async {
    final categories = await _categoryService.getCategories(type: 'video');
    final futures = categories.map((c) async {
      try {
        final videos = await _service.getVideos(categoryId: c.id);
        return Category(
          id: c.id,
          name: c.name,
          nameEn: c.nameEn,
          slug: c.slug,
          coverImageUrl: c.coverImageUrl,
          orderIndex: c.orderIndex,
          type: c.type,
          videoCount: videos.length,
        );
      } catch (_) {
        return Category(
          id: c.id,
          name: c.name,
          nameEn: c.nameEn,
          slug: c.slug,
          coverImageUrl: c.coverImageUrl,
          orderIndex: c.orderIndex,
          type: c.type,
          videoCount: 0,
        );
      }
    });

    return await Future.wait(futures);
  }

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _reload();
    if (widget.openAddForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _didAutoOpenAddForm) return;
        _didAutoOpenAddForm = true;
        _openForm();
      });
    }
  }

  void _reload() {
    setState(() {
      _future = _service.getVideos(
        programId: widget.programId,
        categoryId: widget.categoryId ?? _selectedCategoryId,
      );
    });
  }

  Future<void> _openCategoryForm({Category? current}) async {
    String t(String key) => DashboardI18n.t(context, key);
    final nameController = TextEditingController(text: current?.name ?? '');
    final nameEnController = TextEditingController(text: current?.nameEn ?? '');
    final orderController =
        TextEditingController(text: (current?.orderIndex ?? 0).toString());

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? t('add_category') : t('edit_category')),
          content: SizedBox(
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
                CustomTextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  labelText: t('order_index'),
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
                final item = Category(
                  id: current?.id ?? '',
                  name: nameController.text.trim(),
                  nameEn: nameEnController.text.trim(),
                  slug: current?.slug,
                  coverImageUrl: current?.coverImageUrl,
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  type: widget.programId != null ? 'program' : 'video',
                );

                try {
                  if (current == null) {
                    await _categoryService.createCategory(item);
                  } else {
                    await _categoryService.updateCategory(item);
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

  Future<void> _deleteCategory(String id) async {
    try {
      await _categoryService.deleteCategory(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_category')}: $e',
      );
    }
  }

  Future<void> _openForm({
    VideoItem? current,
    List<VideoItem>? scopedItems,
    String? defaultCategoryType,
  }) async {
    String t(String key) => DashboardI18n.t(context, key);
    final titleController = TextEditingController(text: current?.title ?? '');
    final titleEnController = TextEditingController(text: current?.titleEn ?? '');
    final urlController = TextEditingController(text: current?.youtubeUrl ?? '');
    
    // If we are inside a playlist, category is auto-selected by the route scope.
    final isProgramScoped = widget.programId != null;
    final isRootVideosSection = widget.programId == null && widget.categoryId == null;
    final lockCategorySelection = widget.categoryId != null || isProgramScoped;
    final shouldShowCategoryTypeSelector =
        !lockCategorySelection && !isRootVideosSection && defaultCategoryType == null;
    String selectedCategoryType = defaultCategoryType ?? (isProgramScoped ? 'program' : 'video');

    // In the root "videos news" section, always create/edit against video categories.
    if (isRootVideosSection) {
      selectedCategoryType = 'video';
    }

    final videoCategories = (isProgramScoped || selectedCategoryType == 'program')
      ? <Category>[]
      : await _categoryService.getCategories(type: 'video');
    final programCategories = (isProgramScoped || selectedCategoryType == 'video')
      ? <Category>[]
      : await _categoryService.getCategories(type: 'program');
      
    if (!mounted) return;
    String? selectedCategoryId = widget.categoryId ?? current?.categoryId;

    List<Category> categoriesForType(String type) {
      return type == 'program' ? programCategories : videoCategories;
    }

    if (!lockCategorySelection && selectedCategoryId != null && !isRootVideosSection) {
      final inProgram = programCategories.any((c) => c.id == selectedCategoryId);
      selectedCategoryType = inProgram ? 'program' : 'video';
    }

    if (!lockCategorySelection && selectedCategoryId == null) {
      final available = categoriesForType(selectedCategoryType);
      if (available.length == 1) {
        selectedCategoryId = available.first.id;
      }
    }

    final initialOrderIndex = current?.orderIndex ?? (scopedItems != null
        ? _nextVideoOrderIndex(scopedItems)
        : await _nextVideoOrderIndexForScope(
            programId: widget.programId,
            categoryId: widget.categoryId ?? selectedCategoryId,
          ));
    if (!mounted) return;

    final orderController = TextEditingController(text: initialOrderIndex.toString());
    bool isHidden = current?.isHidden ?? false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            current == null
                ? (isProgramScoped ? t('add_episode') : t('add_video'))
                : (isProgramScoped ? t('edit_episode') : t('edit_video')),
          ),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: titleController,
                      labelText: t('title_ar'),
                    ),
                    CustomTextField(
                      controller: titleEnController,
                      labelText: t('title_en'),
                    ),
                    CustomTextField(
                      controller: urlController,
                      labelText: t('youtube_url'),
                    ),
                    if (shouldShowCategoryTypeSelector)
                      CustomDropdownField<String>(
                        value: selectedCategoryType,
                        labelText: t('category_type'),
                        items: [
                          DropdownMenuItem(
                            value: 'video',
                            child: Text(t('category_type_video')),
                          ),
                          DropdownMenuItem(
                            value: 'program',
                            child: Text(t('category_type_program')),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          setLocalState(() {
                            selectedCategoryType = value;
                            selectedCategoryId = null;
                          });

                          if (current != null) return;
                          final nextIndex = await _nextVideoOrderIndexForScope(
                            categoryId: null,
                          );
                          if (!context.mounted) return;
                          setLocalState(() {
                            orderController.text = nextIndex.toString();
                          });
                        },
                      ),
                    if (!lockCategorySelection)
                      CustomDropdownField<String>(
                        value: selectedCategoryId,
                        labelText: t(
                          selectedCategoryType == 'program'
                              ? 'program_category_required'
                              : 'video_category_required',
                        ),
                        items: [
                          ...categoriesForType(selectedCategoryType).map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        onChanged: lockCategorySelection
                            ? null
                            : (value) async {
                          setLocalState(() => selectedCategoryId = value);
                          if (current != null) return;
                          final nextIndex = await _nextVideoOrderIndexForScope(
                            programId: widget.programId,
                            categoryId: value,
                          );
                          if (!context.mounted) return;
                          setLocalState(() {
                            orderController.text = nextIndex.toString();
                          });
                        },
                      ),
                    CustomTextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      labelText: t('order_index'),
                    ),
                    CustomSwitchTile(
                      value: isHidden,
                      onChanged: (value) => setLocalState(() => isHidden = value),
                      title: t('hidden'),
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
                if (!lockCategorySelection &&
                    (selectedCategoryId == null || selectedCategoryId!.isEmpty)) {
                  await DashboardDialogs.showError(
                    dialogContext,
                    t(
                      selectedCategoryType == 'program'
                          ? 'please_select_program_category'
                          : 'please_select_video_category',
                    ),
                  );
                  return;
                }

                final item = VideoItem(
                  id: current?.id ?? '',
                  title: titleController.text.trim(),
                  titleEn: titleEnController.text.trim(),
                  youtubeUrl: urlController.text.trim(),
                  programId: widget.programId ?? current?.programId,
                  categoryId: selectedCategoryId,
                  thumbnailUrl: current?.thumbnailUrl,
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  publishedAt: current?.publishedAt,
                  createdAt: current?.createdAt ?? DateTime.now(),
                  isHidden: isHidden,
                );

                try {
                  if (current == null) {
                    await _service.createVideo(item);
                  } else {
                    await _service.updateVideo(item);
                  }
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  await DashboardDialogs.showError(
                    dialogContext,
                    '${t('error_saving_video')}: $e',
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
      await _service.deleteVideo(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_video')}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;
    final isScoped = widget.categoryId != null || widget.programId != null;
    final title = widget.categoryName != null
      ? t('category_videos').replaceAll('{name}', widget.categoryName ?? '')
      : widget.programName == null
        ? t('videos')
        : t('program_episodes').replaceAll('{name}', widget.programName ?? '');

    if (!isScoped) {
      return Scaffold(
        body: FutureBuilder<List<Category>>(
          future: _loadCategoriesWithCounts(),
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
              child: categories.isEmpty
                  ? DashboardEmptyState(
                      icon: Icons.video_collection_outlined,
                      title: t('no_categories_found'),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        columns: [
                          DataColumn(label: Text(t('name_ar'))),
                          DataColumn(label: Text(t('name_en'))),
                          DataColumn(label: Text(t('order'))),
                          DataColumn(label: Text(t('views'))),
                          DataColumn(label: Text(t('actions'))),
                        ],
                        rows: categories
                            .map(
                              (item) => DataRow(
                                cells: [
                                  DataCell(Text(item.name)),
                                  DataCell(Text(item.nameEn)),
                                  DataCell(Text(item.orderIndex.toString())),
                                  DataCell(Text(item.videoCount.toString())),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.open_in_new,
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
                                          icon: Icon(Icons.edit, color: scheme.primary),
                                          tooltip: t('edit_category'),
                                          onPressed: () => _openCategoryForm(current: item),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: scheme.error),
                                          tooltip: t('delete'),
                                          onPressed: () => _deleteCategory(item.id),
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
                onPressed: () => _openForm(scopedItems: items, defaultCategoryType: 'video'),
                icon: const Icon(Icons.add),
                label: Text(t('add_news_video')),
              ),
            ],
            child: items.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.ondemand_video_outlined,
                    title: t('no_videos_found'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      columns: [
                        DataColumn(label: Text(t('title_ar'))),
                        DataColumn(label: Text(t('title_en'))),
                        DataColumn(label: Text(t('youtube_url'))),
                        DataColumn(label: Text(t('order'))),
                        DataColumn(label: Text(t('hidden'))),
                        DataColumn(label: Text(t('published_at'))),
                        DataColumn(label: Text(t('actions'))),
                      ],
                      rows: items
                          .map(
                            (item) => DataRow(
                              cells: [
                                DataCell(Text(item.title)),
                                DataCell(Text(item.titleEn)),
                                DataCell(Text(item.youtubeUrl)),
                                DataCell(Text(item.orderIndex.toString())),
                                DataCell(Text(item.isHidden ? t('yes') : t('no'))),
                                DataCell(Text(item.publishedAt?.toString() ?? t('na'))),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: scheme.primary),
                                        onPressed: () => _openForm(current: item, scopedItems: items),
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
