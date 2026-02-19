import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';
import '../models/news_model.dart';

class HomeRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select('id,name,slug,order_index,parent_id')
        .order('order_index', ascending: true);

    return (response as List<dynamic>)
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<NewsModel>> getLatestNews({int limit = 20, int offset = 0}) async {
    final response = await _client
        .from('news')
        .select('id,title,summary,content,image_url,category_id,created_at,is_featured')
        .eq('is_hidden', false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List<dynamic>)
        .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getActiveBreakingNewsTitles() async {
    final nowIso = DateTime.now().toIso8601String();

    final response = await _client
        .from('breaking_news')
        .select('title')
        .eq('is_active', true)
        .lte('start_time', nowIso)
        .gte('end_time', nowIso)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => (item as Map<String, dynamic>)['title'] as String)
        .toList();
  }
}
