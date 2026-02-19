import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/models/ticker_news.dart';
import 'package:newsappjs/dashboard/services/ticker_news_service.dart';
import 'package:uuid/uuid.dart';

class TickerNewsScreen extends StatefulWidget {
  const TickerNewsScreen({super.key});

  @override
  State<TickerNewsScreen> createState() => _TickerNewsScreenState();
}

class _TickerNewsScreenState extends State<TickerNewsScreen> {
  final TickerNewsService _service = TickerNewsService();
  late Future<List<TickerNews>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getTickerNews();
    });
  }

  Future<void> _openForm({TickerNews? current}) async {
    final textController = TextEditingController(text: current?.text ?? '');
    final priorityController =
        TextEditingController(text: (current?.priority ?? 0).toString());
    final linkedController =
        TextEditingController(text: current?.linkedNewsId ?? '');
    bool isActive = current?.isActive ?? true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? 'Add Ticker Item' : 'Edit Ticker Item'),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(labelText: 'Text'),
                    ),
                    TextField(
                      controller: priorityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                    TextField(
                      controller: linkedController,
                      decoration: const InputDecoration(
                        labelText: 'Linked News ID (optional)',
                      ),
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
                final item = TickerNews(
                  id: current?.id ?? const Uuid().v4(),
                  text: textController.text.trim(),
                  isActive: isActive,
                  priority: int.tryParse(priorityController.text.trim()) ?? 0,
                  linkedNewsId: linkedController.text.trim().isEmpty
                      ? null
                      : linkedController.text.trim(),
                  createdAt: current?.createdAt ?? DateTime.now(),
                );

                if (current == null) {
                  await _service.createTickerNews(item);
                } else {
                  await _service.updateTickerNews(item);
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
    await _service.deleteTickerNews(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticker News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: FutureBuilder<List<TickerNews>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return const Center(child: Text('No ticker items found.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Text')),
                DataColumn(label: Text('Priority')),
                DataColumn(label: Text('Active')),
                DataColumn(label: Text('Linked News')),
                DataColumn(label: Text('Actions')),
              ],
              rows: rows
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.text)),
                        DataCell(Text(item.priority.toString())),
                        DataCell(Text(item.isActive ? 'Yes' : 'No')),
                        DataCell(Text(item.linkedNewsId ?? '-')),
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
