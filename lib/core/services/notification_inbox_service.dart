import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/in_app_notification.dart';
import 'local_cache_service.dart';

class NotificationInboxService {
  NotificationInboxService._();

  static final NotificationInboxService instance = NotificationInboxService._();
  static const String _cacheKey = 'in_app_notifications_v1';
  static const int _maxEntries = 100;

  Future<List<InAppNotification>> getNotifications() async {
    final cached = await LocalCacheService.instance.readList(_cacheKey);
    final rows = cached?.data ?? const <Map<String, dynamic>>[];

    final items = rows.map(InAppNotification.fromMap).toList();
    items.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return items;
  }

  Future<void> clear() async {
    await LocalCacheService.instance.delete(_cacheKey);
  }

  Future<void> saveRemoteMessage(
    RemoteMessage message, {
    required String source,
  }) async {
    final now = DateTime.now();
    final messageId = message.messageId;

    final title =
        message.notification?.title ?? (message.data['title'] as String?);
    final body = message.notification?.body ?? (message.data['body'] as String?);

    if ((title == null || title.trim().isEmpty) &&
        (body == null || body.trim().isEmpty)) {
      return;
    }

    final item = InAppNotification(
      id: messageId ?? now.microsecondsSinceEpoch.toString(),
      title: title,
      body: body,
      receivedAt: message.sentTime ?? now,
      source: source,
      data: Map<String, dynamic>.from(message.data),
    );

    final current = await getNotifications();
    final withoutDuplicate =
        current.where((entry) => entry.id != item.id).toList(growable: true);
    withoutDuplicate.insert(0, item);

    if (withoutDuplicate.length > _maxEntries) {
      withoutDuplicate.removeRange(_maxEntries, withoutDuplicate.length);
    }

    await LocalCacheService.instance.writeList(
      _cacheKey,
      withoutDuplicate.map((entry) => entry.toMap()).toList(),
    );
  }
}