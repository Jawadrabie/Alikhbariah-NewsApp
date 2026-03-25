import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/manual_notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManualNotificationsService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  Future<void> _sendPush({required String title, required String body}) async {
    try {
      await _supabase.functions.invoke(
        'send-fcm',
        body: {
          'record': {'title': title, 'body': body},
        },
      );
    } catch (e) {
      debugPrint('Error sending manual push notification: $e');
    }
  }

  Future<List<ManualNotification>> getNotifications() async {
    try {
      final response = await _supabase
          .from('manual_notifications_log')
          .select()
          .order('sent_at', ascending: false);
      return (response as List<dynamic>)
          .map(
            (json) => ManualNotification.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching manual notifications: $e');
      rethrow;
    }
  }

  Future<void> createNotification(ManualNotification item) async {
    try {
      final data = <String, dynamic>{'title': item.title, 'body': item.body};
      await _supabase.from('manual_notifications_log').insert(data);
      await _sendPush(title: item.title, body: item.body);
    } catch (e) {
      debugPrint('Error creating manual notification: $e');
      rethrow;
    }
  }

  Future<void> updateNotification(ManualNotification item) async {
    try {
      final data = Map<String, dynamic>.from(item.toJson())..remove('id');
      await _supabase
          .from('manual_notifications_log')
          .update(data)
          .eq('id', _idValue(item.id));
    } catch (e) {
      debugPrint('Error updating manual notification: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _supabase
          .from('manual_notifications_log')
          .delete()
          .eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error deleting manual notification: $e');
      rethrow;
    }
  }
}
