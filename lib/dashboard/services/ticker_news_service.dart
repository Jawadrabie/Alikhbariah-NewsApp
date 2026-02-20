import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/ticker_news.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TickerNewsService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

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
      if (e.toString().contains('ticker_news.priority does not exist')) {
        final fallbackResponse = await _supabase
            .from('ticker_news')
            .select()
            .order('created_at', ascending: false);
        return (fallbackResponse as List<dynamic>)
            .map((json) => TickerNews.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      debugPrint('Error fetching ticker news: $e');
      rethrow;
    }
  }

  Future<void> createTickerNews(TickerNews item) async {
    final data = Map<String, dynamic>.from(item.toJson())..remove('id');
    try {
      await _supabase.from('ticker_news').insert(data);
    } catch (e) {
      if (e.toString().contains('ticker_news.priority does not exist')) {
        final fallbackData = Map<String, dynamic>.from(data)..remove('priority');
        await _supabase.from('ticker_news').insert(fallbackData);
        return;
      }
      debugPrint('Error creating ticker news: $e');
      rethrow;
    }
  }

  Future<void> updateTickerNews(TickerNews item) async {
    final data = Map<String, dynamic>.from(item.toJson())..remove('id');
    try {
      await _supabase.from('ticker_news').update(data).eq('id', _idValue(item.id));
    } catch (e) {
      if (e.toString().contains('ticker_news.priority does not exist')) {
        final fallbackData = Map<String, dynamic>.from(data)..remove('priority');
        await _supabase.from('ticker_news').update(fallbackData).eq('id', _idValue(item.id));
        return;
      }
      debugPrint('Error updating ticker news: $e');
      rethrow;
    }
  }

  Future<void> deleteTickerNews(String id) async {
    try {
      await _supabase.from('ticker_news').delete().eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error deleting ticker news: $e');
      rethrow;
    }
  }
}
