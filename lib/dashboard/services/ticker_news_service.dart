import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/ticker_news.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TickerNewsService {
  final _supabase = Supabase.instance.client;

  Future<List<TickerNews>> getTickerNews() async {
    try {
      final response = await _supabase
          .from('ticker_news')
          .select()
          .order('priority', ascending: false)
          .order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map((json) => TickerNews.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching ticker news: $e');
      rethrow;
    }
  }

  Future<void> createTickerNews(TickerNews item) async {
    try {
      await _supabase.from('ticker_news').insert(item.toJson());
    } catch (e) {
      debugPrint('Error creating ticker news: $e');
      rethrow;
    }
  }

  Future<void> updateTickerNews(TickerNews item) async {
    try {
      await _supabase.from('ticker_news').update(item.toJson()).eq('id', item.id);
    } catch (e) {
      debugPrint('Error updating ticker news: $e');
      rethrow;
    }
  }

  Future<void> deleteTickerNews(String id) async {
    try {
      await _supabase.from('ticker_news').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting ticker news: $e');
      rethrow;
    }
  }
}
