import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/models/program.dart';
import 'package:newsappjs/dashboard/services/programs_service.dart';
import 'package:uuid/uuid.dart';

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
          title: Text(current == null ? 'Add Program' : 'Edit Program'),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    TextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Order Index'),
                    ),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (value) => setLocalState(() => isActive = value),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
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
                final item = Program(
                  id: current?.id ?? const Uuid().v4(),
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

                if (current == null) {
                  await _service.createProgram(item);
                } else {
                  await _service.updateProgram(item);
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
    await _service.deleteProgram(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: FutureBuilder<List<Program>>(
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
            return const Center(child: Text('No programs found.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Order')),
                DataColumn(label: Text('Active')),
                DataColumn(label: Text('Actions')),
              ],
              rows: items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.name)),
                        DataCell(Text(item.orderIndex.toString())),
                        DataCell(Text(item.isActive ? 'Yes' : 'No')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.video_collection),
                                tooltip: 'Manage Episodes',
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
