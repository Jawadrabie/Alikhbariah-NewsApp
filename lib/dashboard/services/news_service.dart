import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/news.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  Future<List<News>> getNews() async {
    try {
      final response = await _supabase.from('news').select();

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }

      return data.map((item) {
        if (item is News) {
          return item;
        }
        if (item is Map<String, dynamic>) {
          return News.fromJson(item);
        }
        if (item is Map) {
          return News.fromJson(Map<String, dynamic>.from(item));
        }
        throw StateError('Unexpected news item type: ${item.runtimeType}');
      }).toList();
    } catch (e) {
      // Handle error
      debugPrint('Error fetching news: $e');
      rethrow;
    }
  }

  Future<void> createNews(News news) async {
    try {
      final data =
          Map<String, dynamic>.from(news.toJson())
            ..remove('id')
            ..remove('view_count');

      await _supabase.from('news').insert(data);
    } catch (e) {
      debugPrint('Error creating news: $e');
      rethrow;
    }
  }

  Future<void> updateNews(News news) async {
    try {
      final data =
          Map<String, dynamic>.from(news.toJson())
            ..remove('id')
            ..remove('view_count');

      await _supabase.from('news').update(data).eq('id', _idValue(news.id));
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
