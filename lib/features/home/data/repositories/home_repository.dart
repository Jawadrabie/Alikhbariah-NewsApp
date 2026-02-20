import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';
import '../models/featured_slider_settings_model.dart';
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

  PostgrestFilterBuilder<List<Map<String, dynamic>>> _newsBaseQuery() {
    return _client
        .from('news')
        .select('id,title,summary,content,image_url,category_id,created_at,is_featured')
        .eq('is_hidden', false);
  }

  Future<List<NewsModel>> getLatestNews({
    int limit = 20,
    int offset = 0,
    int? categoryId,
  }) async {
    final query = _newsBaseQuery();
    if (categoryId != null) {
      query.eq('category_id', categoryId);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List<dynamic>)
        .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<NewsModel>> getFeaturedNews({int limit = 5}) async {
    final featuredResponse = await _newsBaseQuery()
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);

    final featured = (featuredResponse as List<dynamic>)
        .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
        .toList();

    if (featured.isNotEmpty) {
      return featured;
    }

    final latestFallback = await getLatestNews(limit: limit, offset: 0);
    return latestFallback;
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

  Future<FeaturedSliderSettingsModel> getFeaturedSliderSettings() async {
    const defaultInterval = 3;

    final response = await _client
        .from('app_settings')
        .select('key,value')
        .inFilter('key', ['featured_slider_autoplay', 'featured_slider_interval_seconds']);

    final map = <String, String>{
      for (final row in (response as List<dynamic>))
        (row as Map<String, dynamic>)['key'] as String:
            ((row)['value'] as String? ?? ''),
    };

    final autoplay = (map['featured_slider_autoplay']?.toLowerCase() ?? 'true') == 'true';
    final interval = int.tryParse(map['featured_slider_interval_seconds'] ?? '$defaultInterval') ??
        defaultInterval;

    return FeaturedSliderSettingsModel(
      autoplay: autoplay,
      intervalSeconds: interval < 1 ? defaultInterval : interval,
    );
  }
}
