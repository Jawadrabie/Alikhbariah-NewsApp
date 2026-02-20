import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
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
    String t(String key) => DashboardI18n.t(context, key);
    final now = DateTime.now();
    if (now.isBefore(item.startTime)) {
      return t('breaking_status_coming');
    }
    if (now.isAfter(item.endTime)) {
      return t('breaking_status_ended');
    }
    return t('breaking_status_active');
  }

  Future<void> _delete(String id) async {
    try {
      await _service.deleteBreakingNews(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error')}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('breaking_news')),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/dashboard/breaking-news/add');
          _reload();
        },
        icon: const Icon(Icons.add_alert),
        label: Text(t('add_breaking_news')),
      ),
      body: FutureBuilder<List<BreakingNews>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${t('error')}: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(child: Text(t('no_breaking_news_found')));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(t('title'))),
                DataColumn(label: Text(t('start'))),
                DataColumn(label: Text(t('end'))),
                DataColumn(label: Text(t('status'))),
                DataColumn(label: Text(t('notify'))),
                DataColumn(label: Text(t('actions'))),
              ],
              rows: items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.title)),
                        DataCell(Text(item.startTime.toString())),
                        DataCell(Text(item.endTime.toString())),
                        DataCell(Text(_statusOf(item))),
                        DataCell(Text(item.sendNotification ? t('yes') : t('no'))),
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
