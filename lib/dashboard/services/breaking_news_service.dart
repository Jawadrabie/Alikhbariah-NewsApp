import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/breaking_news.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BreakingNewsService {
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
      debugPrint('Error sending breaking push notification: $e');
    }
  }

  Future<List<BreakingNews>> getBreakingNews() async {
    try {
      final response = await _supabase.from('breaking_news').select();
      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((json) => BreakingNews.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching breaking news: $e');
      rethrow;
    }
  }

  Future<void> createBreakingNews(BreakingNews breakingNews) async {
    try {
      final data = Map<String, dynamic>.from(breakingNews.toJson())
        ..remove('id')
        ..remove('view_count');
      await _supabase.from('breaking_news').insert(data);

      if (breakingNews.sendNotification) {
        await _sendPush(title: breakingNews.title, body: breakingNews.content);
      }
    } catch (e) {
      debugPrint('Error creating breaking news: $e');
      rethrow;
    }
  }

  Future<void> updateBreakingNews(BreakingNews breakingNews) async {
    try {
      final data = Map<String, dynamic>.from(breakingNews.toJson())
        ..remove('id')
        ..remove('view_count');
      await _supabase
          .from('breaking_news')
          .update(data)
          .eq('id', _idValue(breakingNews.id));
    } catch (e) {
      debugPrint('Error updating breaking news: $e');
      rethrow;
    }
  }

  Future<void> deleteBreakingNews(String id) async {
    try {
      await _supabase.from('breaking_news').delete().eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error deleting breaking news: $e');
      rethrow;
    }
  }
}
