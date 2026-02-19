import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/breaking_news.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BreakingNewsService {
  final _supabase = Supabase.instance.client;

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
      await _supabase.from('breaking_news').insert(breakingNews.toJson());
    } catch (e) {
      debugPrint('Error creating breaking news: $e');
      rethrow;
    }
  }

  Future<void> updateBreakingNews(BreakingNews breakingNews) async {
    try {
      await _supabase
          .from('breaking_news')
          .update(breakingNews.toJson())
          .eq('id', breakingNews.id);
    } catch (e) {
      debugPrint('Error updating breaking news: $e');
      rethrow;
    }
  }

  Future<void> deleteBreakingNews(String id) async {
    try {
      await _supabase.from('breaking_news').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting breaking news: $e');
      rethrow;
    }
  }
}
