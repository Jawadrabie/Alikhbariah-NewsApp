import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/breaking_news.dart';
import 'package:newsappjs/dashboard/services/breaking_news_service.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

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

  String _formatDateTime(DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(value);
    final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value));
    return '$date $time';
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
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
          return DashboardSectionView(
            title: t('breaking_news'),
            actions: [
              FilledButton.icon(
                onPressed: () async {
                  await context.push('/dashboard/breaking-news/add');
                  _reload();
                },
                icon: const Icon(Icons.add_alert),
                label: Text(t('add_breaking_news')),
              ),
            ],
            child:
                items.isEmpty
                    ? DashboardEmptyState(
                      icon: Icons.new_releases_outlined,
                      title: t('no_breaking_news_found'),
                    )
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        columns: [
                          DataColumn(label: Text(t('title'))),
                          DataColumn(label: Text(t('start'))),
                          DataColumn(label: Text(t('end'))),
                          DataColumn(label: Text(t('status'))),
                          DataColumn(label: Text(t('notify'))),
                          DataColumn(label: Text(t('view_count'))),
                          DataColumn(label: Text(t('actions'))),
                        ],
                        rows:
                            items
                                .map(
                                  (item) => DataRow(
                                    cells: [
                                      DataCell(Text(item.title)),
                                      DataCell(
                                        Text(_formatDateTime(item.startTime)),
                                      ),
                                      DataCell(
                                        Text(_formatDateTime(item.endTime)),
                                      ),
                                      DataCell(Text(_statusOf(item))),
                                      DataCell(
                                        Text(
                                          item.sendNotification
                                              ? t('yes')
                                              : t('no'),
                                        ),
                                      ),
                                      DataCell(Text(item.viewCount.toString())),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: scheme.primary,
                                              ),
                                              onPressed: () async {
                                                await context.push(
                                                  '/dashboard/breaking-news/edit/${item.id}',
                                                  extra: item,
                                                );
                                                _reload();
                                              },
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
