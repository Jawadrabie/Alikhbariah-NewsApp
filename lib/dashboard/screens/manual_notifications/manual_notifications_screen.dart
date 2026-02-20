import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/manual_notification.dart';
import 'package:newsappjs/dashboard/services/manual_notifications_service.dart';

class ManualNotificationsScreen extends StatefulWidget {
  const ManualNotificationsScreen({super.key});

  @override
  State<ManualNotificationsScreen> createState() =>
      _ManualNotificationsScreenState();
}

class _ManualNotificationsScreenState extends State<ManualNotificationsScreen> {
  final ManualNotificationsService _service = ManualNotificationsService();
  late Future<List<ManualNotification>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getNotifications();
    });
  }

  Future<void> _openForm({ManualNotification? current}) async {
    String t(String key) => DashboardI18n.t(context, key);
    final titleController = TextEditingController(text: current?.title ?? '');
    final bodyController = TextEditingController(text: current?.body ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? t('add_manual_notification') : t('edit_manual_notification')),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: t('notification_title')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: t('notification_body')),
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
                final item = ManualNotification(
                  id: current?.id ?? '',
                  title: titleController.text.trim(),
                  body: bodyController.text.trim(),
                  sentAt: current?.sentAt ?? DateTime.now(),
                  createdBy: current?.createdBy,
                  viewCount: current?.viewCount ?? 0,
                );

                try {
                  if (current == null) {
                    await _service.createNotification(item);
                  } else {
                    await _service.updateNotification(item);
                  }
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  await DashboardDialogs.showError(
                    dialogContext,
                    '${t('error_saving_manual_notification')}: $e',
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
      await _service.deleteNotification(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_manual_notification')}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('manual_notifications')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_alert),
        label: Text(t('add_manual_notification')),
      ),
      body: FutureBuilder<List<ManualNotification>>(
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
            return Center(child: Text(t('no_manual_notifications')));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(t('title'))),
                DataColumn(label: Text(t('text'))),
                DataColumn(label: Text(t('sent_date'))),
                DataColumn(label: Text(t('view_count'))),
                DataColumn(label: Text(t('actions'))),
              ],
              rows: items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.title)),
                        DataCell(SizedBox(width: 420, child: Text(item.body))),
                        DataCell(Text(item.sentAt.toString())),
                        DataCell(Text(item.viewCount.toString())),
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
