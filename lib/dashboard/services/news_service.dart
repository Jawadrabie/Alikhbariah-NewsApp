import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/news.dart';
import 'package:newsappjs/dashboard/services/dashboard_translation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsService {
  final _supabase = Supabase.instance.client;
  final DashboardTranslationService _translationService = DashboardTranslationService();
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  String _notificationBodyFromContent(String content) {
    final plain = content.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (plain.isEmpty) return '';
    if (plain.length <= 120) return plain;
    return '${plain.substring(0, 120)}...';
  }

  Future<void> _sendPush({required String title, required String body}) async {
    try {
      await _supabase.functions.invoke(
        'send-fcm',
        body: {
          'record': {
            'title': title,
            'body': body,
          },
        },
      );
    } catch (e) {
      debugPrint('Error sending push notification: $e');
    }
  }

  Future<List<News>> getNews() async {
    try {
      final response = await _supabase.from('news').select();
      
      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      
      return data.map((json) => News.fromJson(json)).toList();
    } catch (e) {
      // Handle error
      debugPrint('Error fetching news: $e');
      rethrow;
    }
  }

  Future<void> createNews(News news) async {
    try {
      final data = Map<String, dynamic>.from(news.toJson())
        ..remove('id')
        ..remove('view_count');

      final translated = await _translationService.translateNewsFields(
        title: news.title,
        content: news.content,
      );
      data.addAll(translated);

      try {
        await _supabase.from('news').insert(data);
      } on PostgrestException catch (error) {
        final message = error.message.toLowerCase();
        final hasMissingTranslatedColumns =
            message.contains('title_en') || message.contains('content_en');
        if (!hasMissingTranslatedColumns) {
          rethrow;
        }

        data
          ..remove('title_en')
          ..remove('content_en');
        await _supabase.from('news').insert(data);
      }

      if (news.sentNotification) {
        final body = _notificationBodyFromContent(news.content);
        await _sendPush(
          title: news.title,
          body: body.isEmpty ? news.title : body,
        );
      }
    } catch (e) {
      debugPrint('Error creating news: $e');
      rethrow;
    }
  }

  Future<void> updateNews(News news) async {
    try {
      final data = Map<String, dynamic>.from(news.toJson())
        ..remove('id')
        ..remove('view_count');

      final translated = await _translationService.translateNewsFields(
        title: news.title,
        content: news.content,
      );
      data.addAll(translated);

      try {
        await _supabase.from('news').update(data).eq('id', _idValue(news.id));
      } on PostgrestException catch (error) {
        final message = error.message.toLowerCase();
        final hasMissingTranslatedColumns =
            message.contains('title_en') || message.contains('content_en');
        if (!hasMissingTranslatedColumns) {
          rethrow;
        }

        data
          ..remove('title_en')
          ..remove('content_en');
        await _supabase.from('news').update(data).eq('id', _idValue(news.id));
      }
    } catch (e) {
      debugPrint('Error updating news: $e');
      rethrow;
    }
  }

  Future<void> updateFeaturedStatus({
    required String id,
    required bool isFeatured,
  }) async {
    try {
      await _supabase
          .from('news')
          .update({'is_featured': isFeatured})
          .eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error updating featured status: $e');
      rethrow;
    }
  }

  Future<void> deleteNews(String id) async {
    try {
      await _supabase.from('news').delete().eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error deleting news: $e');
      rethrow;
    }
  }
}
