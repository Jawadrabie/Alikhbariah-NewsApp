import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:newsappjs/core/models/in_app_notification.dart';
import 'package:newsappjs/core/services/notification_inbox_service.dart';

import '../../../../core/localization/l10n_extensions.dart';

class NotificationsInboxScreen extends StatefulWidget {
  const NotificationsInboxScreen({super.key});

  @override
  State<NotificationsInboxScreen> createState() => _NotificationsInboxScreenState();
}

class _NotificationsInboxScreenState extends State<NotificationsInboxScreen> {
  late Future<List<InAppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationInboxService.instance.getNotifications();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = NotificationInboxService.instance.getNotifications();
    });
    await _future;
  }

  Future<void> _clearAll() async {
    await NotificationInboxService.instance.clear();
    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(content: Text(context.l10n.notificationsInboxCleared)),
    );
  }

  String _formatDate(BuildContext context, DateTime dateTime) {
    final localeName = Localizations.localeOf(context).toString();
    return intl.DateFormat.yMd(localeName).add_jm().format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: l10n.refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: _clearAll,
            tooltip: l10n.notificationsInboxClearAll,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<InAppNotification>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.notificationsInboxLoadFailed(
                        snapshot.error.toString(),
                      ),
                    ),
                  ),
                ],
              );
            }

            final notifications = snapshot.data ?? const <InAppNotification>[];
            if (notifications.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  const Icon(
                    Icons.notifications_off_outlined,
                    size: 42,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 10),
                  Center(child: Text(l10n.notificationsInboxEmpty)),
                ],
              );
            }

            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = notifications[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.notifications_active_outlined),
                  ),
                  title: Text(
                    (item.title == null || item.title!.trim().isEmpty)
                        ? l10n.notificationsInboxUntitled
                        : item.title!,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.body != null && item.body!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(item.body!),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _formatDate(context, item.receivedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}