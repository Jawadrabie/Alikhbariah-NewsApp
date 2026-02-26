import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/video_item.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/services/programs_service.dart';
import 'package:newsappjs/dashboard/services/videos_service.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class VideosScreen extends StatefulWidget {
  final String? programId;
  final String? programName;

  const VideosScreen({super.key, this.programId, this.programName});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final VideosService _service = VideosService();
  final CategoryService _categoryService = CategoryService();
  final ProgramsService _programsService = ProgramsService();
  late Future<List<VideoItem>> _future;
  String? _selectedCategoryId;
  String? _selectedProgramId;

  @override
  void initState() {
    super.initState();
    _selectedProgramId = widget.programId;
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getVideos(
        programId: widget.programId ?? _selectedProgramId,
        categoryId: _selectedCategoryId,
      );
    });
  }

  Future<void> _openForm({VideoItem? current}) async {
    String t(String key) => DashboardI18n.t(context, key);
    final titleController = TextEditingController(text: current?.title ?? '');
    final urlController = TextEditingController(text: current?.youtubeUrl ?? '');
    final thumbController = TextEditingController(text: current?.thumbnailUrl ?? '');
    final orderController =
        TextEditingController(text: (current?.orderIndex ?? 0).toString());
    final categories = await _categoryService.getCategories(type: 'video');
    final programs = await _programsService.getPrograms();
    if (!mounted) return;
    String? selectedCategoryId = current?.categoryId;
    String? selectedProgramId = widget.programId ?? current?.programId;
    bool isHidden = current?.isHidden ?? false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? t('add_video') : t('edit_video')),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: t('title')),
                    ),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(labelText: t('youtube_url')),
                    ),
                    TextField(
                      controller: thumbController,
                      decoration: InputDecoration(
                        labelText: t('thumbnail_url_optional'),
                      ),
                    ),
                    TextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: t('order_index')),
                    ),
                    DropdownButtonFormField<String?>(
                      value: selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: t('video_category_optional'),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(t('na')),
                        ),
                        ...categories.map(
                          (item) => DropdownMenuItem<String?>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setLocalState(() => selectedCategoryId = value);
                      },
                    ),
                    if (widget.programId == null)
                      DropdownButtonFormField<String?>(
                        value: selectedProgramId,
                        decoration: InputDecoration(
                          labelText: t('program_optional'),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(t('na')),
                          ),
                          ...programs.map(
                            (item) => DropdownMenuItem<String?>(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setLocalState(() => selectedProgramId = value);
                        },
                      ),
                    SwitchListTile(
                      value: isHidden,
                      onChanged: (value) => setLocalState(() => isHidden = value),
                      contentPadding: EdgeInsets.zero,
                      title: Text(t('hidden')),
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
                final item = VideoItem(
                  id: current?.id ?? '',
                  title: titleController.text.trim(),
                  youtubeUrl: urlController.text.trim(),
                    programId: selectedProgramId,
                    categoryId: selectedCategoryId,
                  thumbnailUrl: thumbController.text.trim().isEmpty
                      ? null
                      : thumbController.text.trim(),
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
    final title = widget.programName == null
      ? t('videos')
      : t('program_episodes').replaceAll('{name}', widget.programName ?? '');

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
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: Text(t('add_video')),
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
                        DataColumn(label: Text(t('title'))),
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
                                DataCell(Text(item.youtubeUrl)),
                                DataCell(Text(item.orderIndex.toString())),
                                DataCell(Text(item.isHidden ? t('yes') : t('no'))),
                                DataCell(Text(item.publishedAt?.toString() ?? t('na'))),
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
