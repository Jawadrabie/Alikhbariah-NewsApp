import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/models/video_item.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/services/videos_service.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final CategoryService _service = CategoryService();
  final VideosService _videosService = VideosService();
  late Future<List<Category>> _future;

  int _nextOrderIndex(List<Category> programs) {
    if (programs.isEmpty) return 1;
    final maxOrder = programs
        .map((item) => item.orderIndex)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  int _nextEpisodeOrderIndex(List<VideoItem> videos) {
    if (videos.isEmpty) return 1;
    final maxOrder = videos
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
      _future = _service.getCategories(type: 'program');
    });
  }

  Future<void> _openForm({
    Category? current,
    required List<Category> programs,
  }) async {
    String t(String key) => DashboardI18n.t(context, key);

    final nameController = TextEditingController(text: current?.name ?? '');
    final nameEnController = TextEditingController(text: current?.nameEn ?? '');
    final orderController = TextEditingController(
      text: (current?.orderIndex ?? _nextOrderIndex(programs)).toString(),
    );
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
                  nameEn: nameEnController.text.trim(),
                  slug: current?.slug,
                  coverImageUrl: current?.coverImageUrl,
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  type: 'program',
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

  Future<void> _openEpisodeForm({required List<Category> programs}) async {
    String t(String key) => DashboardI18n.t(context, key);
    if (programs.isEmpty) {
      await DashboardDialogs.showError(context, t('no_programs_found'));
      return;
    }

    final titleController = TextEditingController();
    final titleEnController = TextEditingController();
    final urlController = TextEditingController();
    final orderController = TextEditingController(text: '1');
    String selectedProgramId = programs.first.id;
    bool isHidden = false;

    Future<void> updateOrder(StateSetter setLocalState) async {
      final videos = await _videosService.getVideos(
        categoryId: selectedProgramId,
      );
      if (!mounted) return;
      setLocalState(() {
        orderController.text = _nextEpisodeOrderIndex(videos).toString();
      });
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t('add_episode')),
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
                    CustomDropdownField<String>(
                      value: selectedProgramId,
                      labelText: t('program_category_required'),
                      items:
                          programs
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item.id,
                                  child: Text(item.name),
                                ),
                              )
                              .toList(),
                      onChanged: (value) async {
                        if (value == null) return;
                        setLocalState(() => selectedProgramId = value);
                        await updateOrder(setLocalState);
                      },
                    ),
                    CustomTextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      labelText: t('order_index'),
                    ),
                    CustomSwitchTile(
                      value: isHidden,
                      onChanged:
                          (value) => setLocalState(() => isHidden = value),
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
                if (titleController.text.trim().isEmpty ||
                    urlController.text.trim().isEmpty) {
                  await DashboardDialogs.showError(
                    dialogContext,
                    t('please_fill_all_fields'),
                  );
                  return;
                }

                final item = VideoItem(
                  id: '',
                  title: titleController.text.trim(),
                  titleEn: titleEnController.text.trim(),
                  youtubeUrl: urlController.text.trim(),
                  programId: null,
                  categoryId: selectedProgramId,
                  thumbnailUrl: null,
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  publishedAt: DateTime.now(),
                  createdAt: DateTime.now(),
                  isHidden: isHidden,
                );

                try {
                  await _videosService.createVideo(item);
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
            title: t('programs'),
            actions: [
              FilledButton.icon(
                onPressed: () => _openForm(programs: items),
                icon: const Icon(Icons.add),
                label: Text(t('add_program')),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: () => _openEpisodeForm(programs: items),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(t('add_episode')),
              ),
            ],
            child:
                items.isEmpty
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
                          DataColumn(label: Text(t('name_ar'))),
                          DataColumn(label: Text(t('name_en'))),
                          DataColumn(label: Text(t('order'))),
                          DataColumn(label: Text(t('actions'))),
                        ],
                        rows:
                            items
                                .map(
                                  (item) => DataRow(
                                    cells: [
                                      DataCell(Text(item.name)),
                                      DataCell(Text(item.nameEn)),
                                      DataCell(
                                        Text(item.orderIndex.toString()),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.video_collection,
                                                color: scheme.secondary,
                                              ),
                                              tooltip: t('manage_episodes'),
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
                                                Icons.edit,
                                                color: scheme.primary,
                                              ),
                                              onPressed:
                                                  () => _openForm(
                                                    current: item,
                                                    programs: items,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: scheme.error,
                                              ),
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
