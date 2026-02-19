import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/news_model.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  // Fetch all categories (ordered by order_index)
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('order_index', ascending: true);

    final data = response as List<dynamic>;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  // Fetch latest news with pagination
  Future<List<NewsModel>> getLatestNews({int limit = 10, int offset = 0}) async {
    final response = await _client
        .from('news')
        .select()
        .eq('is_hidden', false)
        .order('created_at', ascending: false) // Latest first
        .range(offset, offset + limit - 1);

    final data = response as List<dynamic>;
    return data.map((json) => NewsModel.fromJson(json)).toList();
  }

  // Fetch breaking news (active only)
  Future<List<Map<String, dynamic>>> getActiveBreakingNews() async {
    final response = await _client
        .from('breaking_news')
        .select()
        .eq('is_active', true)
        .lte('start_time', DateTime.now().toIso8601String())
        .gte('end_time', DateTime.now().toIso8601String());

    return List<Map<String, dynamic>>.from(response);
  }
}
