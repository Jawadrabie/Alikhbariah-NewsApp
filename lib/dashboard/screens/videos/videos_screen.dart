import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/models/video_item.dart';
import 'package:newsappjs/dashboard/services/videos_service.dart';
import 'package:uuid/uuid.dart';

class VideosScreen extends StatefulWidget {
  final String? programId;
  final String? programName;

  const VideosScreen({super.key, this.programId, this.programName});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final VideosService _service = VideosService();
  late Future<List<VideoItem>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getVideos(programId: widget.programId);
    });
  }

  Future<void> _openForm({VideoItem? current}) async {
    final titleController = TextEditingController(text: current?.title ?? '');
    final urlController = TextEditingController(text: current?.youtubeUrl ?? '');
    final thumbController = TextEditingController(text: current?.thumbnailUrl ?? '');
    final orderController =
        TextEditingController(text: (current?.orderIndex ?? 0).toString());
    bool isHidden = current?.isHidden ?? false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? 'Add Video' : 'Edit Video'),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(labelText: 'YouTube URL'),
                    ),
                    TextField(
                      controller: thumbController,
                      decoration:
                          const InputDecoration(labelText: 'Thumbnail URL (optional)'),
                    ),
                    TextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Order Index'),
                    ),
                    SwitchListTile(
                      value: isHidden,
                      onChanged: (value) => setLocalState(() => isHidden = value),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hidden'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final item = VideoItem(
                  id: current?.id ?? const Uuid().v4(),
                  title: titleController.text.trim(),
                  youtubeUrl: urlController.text.trim(),
                  programId: widget.programId ?? current?.programId,
                  categoryId: current?.categoryId,
                  thumbnailUrl: thumbController.text.trim().isEmpty
                      ? null
                      : thumbController.text.trim(),
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  publishedAt: current?.publishedAt,
                  createdAt: current?.createdAt ?? DateTime.now(),
                  isHidden: isHidden,
                );

                if (current == null) {
                  await _service.createVideo(item);
                } else {
                  await _service.updateVideo(item);
                }

                if (!mounted) return;
                Navigator.of(dialogContext).pop();
                _reload();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete(String id) async {
    await _service.deleteVideo(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.programName == null
        ? 'Videos'
        : 'Program Episodes - ${widget.programName}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: FutureBuilder<List<VideoItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No videos found.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('YouTube URL')),
                DataColumn(label: Text('Order')),
                DataColumn(label: Text('Hidden')),
                DataColumn(label: Text('Published At')),
                DataColumn(label: Text('Actions')),
              ],
              rows: items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.title)),
                        DataCell(Text(item.youtubeUrl)),
                        DataCell(Text(item.orderIndex.toString())),
                        DataCell(Text(item.isHidden ? 'Yes' : 'No')),
                        DataCell(Text(item.publishedAt?.toString() ?? '-')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openForm(current: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
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
        },
      ),
    );
  }
}
