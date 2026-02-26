import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/ticker_news.dart';
import 'package:newsappjs/dashboard/services/ticker_news_service.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

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
    String t(String key) => DashboardI18n.t(context, key);
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
          title: Text(current == null ? t('add_ticker_item') : t('edit_ticker_item')),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(labelText: t('text')),
                    ),
                    TextField(
                      controller: priorityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: t('priority')),
                    ),
                    TextField(
                      controller: linkedController,
                      decoration: InputDecoration(
                        labelText: t('linked_news_id_optional'),
                      ),
                    ),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (value) => setLocalState(() => isActive = value),
                      contentPadding: EdgeInsets.zero,
                      title: Text(t('active')),
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
                final item = TickerNews(
                  id: current?.id ?? '',
                  text: textController.text.trim(),
                  isActive: isActive,
                  priority: int.tryParse(priorityController.text.trim()) ?? 0,
                  linkedNewsId: linkedController.text.trim().isEmpty
                      ? null
                      : linkedController.text.trim(),
                  createdAt: current?.createdAt ?? DateTime.now(),
                );

                try {
                  if (current == null) {
                    await _service.createTickerNews(item);
                  } else {
                    await _service.updateTickerNews(item);
                  }
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  await DashboardDialogs.showError(
                    dialogContext,
                    '${t('error_saving_ticker_item')}: $e',
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
      await _service.deleteTickerNews(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_ticker_item')}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder<List<TickerNews>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${t('error')}: ${snapshot.error}'));
          }
          final rows = snapshot.data ?? [];
          return DashboardSectionView(
            title: t('ticker_news'),
            actions: [
              FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: Text(t('add_ticker_item')),
              ),
            ],
            child: rows.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.linear_scale,
                    title: t('no_ticker_items_found'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      columns: [
                        DataColumn(label: Text(t('text'))),
                        DataColumn(label: Text(t('priority'))),
                        DataColumn(label: Text(t('active'))),
                        DataColumn(label: Text(t('linked_news'))),
                        DataColumn(label: Text(t('actions'))),
                      ],
                      rows: rows
                          .map(
                            (item) => DataRow(
                              cells: [
                                DataCell(Text(item.text)),
                                DataCell(Text(item.priority.toString())),
                                DataCell(Text(item.isActive ? t('yes') : t('no'))),
                                DataCell(Text(item.linkedNewsId ?? t('na'))),
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
