import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/models/breaking_news.dart';
import 'package:newsappjs/dashboard/services/breaking_news_service.dart';

class BreakingNewsScreen extends StatefulWidget {
  const BreakingNewsScreen({super.key});

  @override
  State<BreakingNewsScreen> createState() => _BreakingNewsScreenState();
}

class _BreakingNewsScreenState extends State<BreakingNewsScreen> {
  final BreakingNewsService _service = BreakingNewsService();
  late Future<List<BreakingNews>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getBreakingNews();
    });
  }

  String _statusOf(BreakingNews item) {
    final now = DateTime.now();
    if (now.isBefore(item.startTime)) {
      return 'Coming';
    }
    if (now.isAfter(item.endTime)) {
      return 'Ended';
    }
    return 'Active';
  }

  Future<void> _delete(String id) async {
    await _service.deleteBreakingNews(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breaking News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/dashboard/breaking-news/add');
              _reload();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<BreakingNews>>(
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
            return const Center(child: Text('No breaking news found.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Start')),
                DataColumn(label: Text('End')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Notify')),
                DataColumn(label: Text('Actions')),
              ],
              rows: items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.title)),
                        DataCell(Text(item.startTime.toString())),
                        DataCell(Text(item.endTime.toString())),
                        DataCell(Text(_statusOf(item))),
                        DataCell(Text(item.sendNotification ? 'Yes' : 'No')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await context.push(
                                    '/dashboard/breaking-news/edit/${item.id}',
                                    extra: item,
                                  );
                                  _reload();
                                },
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
