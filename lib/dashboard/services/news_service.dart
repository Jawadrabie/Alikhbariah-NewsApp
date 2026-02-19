import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/news.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsService {
  final _supabase = Supabase.instance.client;

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
      await _supabase.from('news').insert(news.toJson());
    } catch (e) {
      debugPrint('Error creating news: $e');
      rethrow;
    }
  }

  Future<void> updateNews(News news) async {
    try {
      await _supabase.from('news').update(news.toJson()).eq('id', news.id);
    } catch (e) {
      debugPrint('Error updating news: $e');
      rethrow;
    }
  }

  Future<void> deleteNews(String id) async {
    try {
      await _supabase.from('news').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting news: $e');
      rethrow;
    }
  }
}
