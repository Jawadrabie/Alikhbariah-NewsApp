import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/local_cache_service.dart';
import '../models/category_model.dart';
import '../models/featured_slider_settings_model.dart';
import '../models/news_model.dart';

class HomeRepository {
  SupabaseClient get _client => Supabase.instance.client;
  final LocalCacheService _cache = LocalCacheService.instance;

  static const Duration _categoriesCacheTtl = Duration(hours: 6);
  static const Duration _newsCacheTtl = Duration(minutes: 10);
  static const Duration _featuredCacheTtl = Duration(minutes: 10);
  static const Duration _breakingCacheTtl = Duration(seconds: 30);
  static const Duration _settingsCacheTtl = Duration(hours: 1);

  // --- Synchronous Getters (For Instant Load) ---

  List<CategoryModel>? getCachedCategories({String languageCode = 'ar'}) {
    final cacheKey = 'home_categories_${languageCode.toLowerCase()}';
    final cached = _cache.readListSync(cacheKey);
    if (cached != null) {
      return _mapCategories(cached.data, languageCode: languageCode);
    }
    return null;
  }

  List<NewsModel>? getCachedLatestNews({
    String languageCode = 'ar',
    int limit = 20,
    int offset = 0,
    int? categoryId,
    String? searchQuery,
  }) {
    final cacheKey = _latestNewsCacheKey(
      languageCode: languageCode,
      limit: limit,
      offset: offset,
      categoryId: categoryId,
      searchQuery: searchQuery,
    );

    final cached = _cache.readListSync(cacheKey);
    if (cached != null) {
      return _mapNews(cached.data, languageCode: languageCode);
    }
    return null;
  }

  List<NewsModel>? getCachedFeaturedNews({
    String languageCode = 'ar',
    int limit = 5,
  }) {
    final cacheKey = 'home_featured_${languageCode.toLowerCase()}_$limit';
    final cached = _cache.readListSync(cacheKey);
    if (cached != null) {
      // Note: mapping logic requires list of maps
      try {
         return _mapNews(cached.data, languageCode: languageCode);
      } catch (_) {
        return null; // Fallback if data structure mismatch
      }
    }
    return null;
  }

  List<String>? getCachedBreakingNewsTitles({String languageCode = 'ar'}) {
    final normalizedLanguage = languageCode.toLowerCase();
    final cacheKey = 'home_breaking_$normalizedLanguage';
    final cached = _cache.readListSync(cacheKey);
    if (cached != null) {
       try {
         return _mapBreakingTitles(cached.data, languageCode: normalizedLanguage);
       } catch (_) {
         return null;
       }
    }
    return null;
  }

  FeaturedSliderSettingsModel? getCachedFeaturedSliderSettings() {
    const cacheKey = 'home_featured_slider_settings';
    final cached = _cache.readMapSync(cacheKey);
    if (cached != null) {
        return _settingsFromMap(cached.data, defaultInterval: 3);
    }
    return null;
  }

  // --- End Synchronous Getters ---

  Future<List<CategoryModel>> getCategories({
    String languageCode = 'ar',
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'home_categories_${languageCode.toLowerCase()}';
    final cached = await _cache.readList(cacheKey);
    final hasFreshCache = !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _categoriesCacheTtl;
    if (hasFreshCache) {
      return _mapCategories(cached.data, languageCode: languageCode);
    }

    try {
      final response = await _client
          .from('categories')
          .select('*')
          .eq('type', 'news')
          .order('order_index', ascending: true);

      final rows = _toMapList(response);
      await _cache.writeList(cacheKey, rows);
      return _mapCategories(rows, languageCode: languageCode);
    } catch (_) {
      if (cached != null) {
        return _mapCategories(cached.data, languageCode: languageCode);
      }
      rethrow;
    }
  }

  List<CategoryModel> _mapCategories(
    List<Map<String, dynamic>> rows, {
    required String languageCode,
  }) {
    return rows
        .map(
          (item) => CategoryModel.fromJson(
            item,
            languageCode: languageCode,
          ),
        )
        .toList();
  }

  PostgrestFilterBuilder<List<Map<String, dynamic>>> _newsBaseQuery() {
    return _client
        .from('news')
        .select('*')
        .eq('is_hidden', false);
  }

  Future<List<NewsModel>> getLatestNews({
    String languageCode = 'ar',
    int limit = 20,
    int offset = 0,
    int? categoryId,
    String? searchQuery,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _latestNewsCacheKey(
      languageCode: languageCode,
      limit: limit,
      offset: offset,
      categoryId: categoryId,
      searchQuery: searchQuery,
    );

    final cached = await _cache.readList(cacheKey);
    final hasFreshCache = !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _newsCacheTtl;
    if (hasFreshCache) {
      return _mapNews(cached.data, languageCode: languageCode);
    }

    PostgrestFilterBuilder<List<Map<String, dynamic>>> query = _newsBaseQuery();
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    final normalizedSearch = searchQuery?.trim();
    if (normalizedSearch != null && normalizedSearch.isNotEmpty) {
      final safeSearch = _sanitizeSearchTerm(normalizedSearch);
      if (safeSearch.isNotEmpty) {
        final pattern = '%$safeSearch%';
        query = query.or('title.ilike.$pattern,content.ilike.$pattern');
      }
    }

    try {
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final rows = _toMapList(response);
      await _cache.writeList(cacheKey, rows);
      return _mapNews(rows, languageCode: languageCode);
    } catch (_) {
      if (cached != null) {
        return _mapNews(cached.data, languageCode: languageCode);
      }
      rethrow;
    }
  }

  String _latestNewsCacheKey({
    required String languageCode,
    required int limit,
    required int offset,
    required int? categoryId,
    required String? searchQuery,
  }) {
    final query = searchQuery?.trim() ?? '';
    final normalizedQuery = query.isEmpty ? '' : Uri.encodeComponent(query.toLowerCase());
    return 'home_news_${languageCode.toLowerCase()}_${categoryId ?? 'all'}_${offset}_${limit}_$normalizedQuery';
  }

  String _sanitizeSearchTerm(String value) {
    return value
        .replaceAll(',', ' ')
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .trim();
  }

  Future<List<NewsModel>> getFeaturedNews({
    String languageCode = 'ar',
    int limit = 5,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'home_featured_${languageCode.toLowerCase()}_$limit';
    final cached = await _cache.readList(cacheKey);
    final hasFreshCache = !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _featuredCacheTtl;
    if (hasFreshCache) {
      return _mapNews(cached.data, languageCode: languageCode);
    }

    try {
      final featuredResponse = await _newsBaseQuery()
          .eq('is_featured', true)
          .limit(limit);

      final featuredRows = _toMapList(featuredResponse);
      final featured = _mapNews(featuredRows, languageCode: languageCode);

      if (featured.isNotEmpty) {
        await _cache.writeList(cacheKey, featuredRows);
        return featured;
      }

      final latestFallback = await getLatestNews(
        languageCode: languageCode,
        limit: limit,
        offset: 0,
        forceRefresh: forceRefresh,
      );
      return latestFallback;
    } catch (_) {
      if (cached != null) {
        return _mapNews(cached.data, languageCode: languageCode);
      }
      rethrow;
    }
  }

  List<NewsModel> _mapNews(
    List<Map<String, dynamic>> rows, {
    required String languageCode,
  }) {
    return rows
        .map(
          (item) => NewsModel.fromJson(
            item,
            languageCode: languageCode,
          ),
        )
        .toList();
  }

  Future<List<String>> getActiveBreakingNewsTitles({
    String languageCode = 'ar',
    bool forceRefresh = false,
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    final normalizedLanguage = languageCode.toLowerCase();
    final cacheKey = 'home_breaking_$normalizedLanguage';

    final cached = await _cache.readList(cacheKey);
    final hasFreshCache = !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _breakingCacheTtl;
    if (hasFreshCache) {
      return _mapBreakingTitles(
        cached.data,
        languageCode: normalizedLanguage,
      );
    }

    try {
      final response = await _client
          .from('breaking_news')
          .select('*')
          .eq('is_active', true)
          .lte('start_time', nowIso)
          .gte('end_time', nowIso)
          .order('created_at', ascending: false);

      final rows = _toMapList(response);
      await _cache.writeList(cacheKey, rows);
      return _mapBreakingTitles(rows, languageCode: normalizedLanguage);
    } catch (_) {
      if (cached != null) {
        return _mapBreakingTitles(cached.data, languageCode: normalizedLanguage);
      }
      rethrow;
    }
  }

  List<String> _mapBreakingTitles(
    List<Map<String, dynamic>> rows, {
    required String languageCode,
  }) {
    final fallbackLanguage = languageCode == 'en' ? 'ar' : 'en';
    return rows
        .map(
          (item) => _readText(item['title_$languageCode']) ??
              _readText(item['title']) ??
              _readText(item['title_$fallbackLanguage']) ??
              '',
        )
        .where((title) => title.trim().isNotEmpty)
        .toList();
  }

  String? _readText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  Future<FeaturedSliderSettingsModel> getFeaturedSliderSettings({
    bool forceRefresh = false,
  }) async {
    const defaultInterval = 3;
    const cacheKey = 'home_featured_slider_settings';

    final cached = await _cache.readMap(cacheKey);
    final hasFreshCache = !forceRefresh &&
      cached != null &&
        DateTime.now().difference(cached.cachedAt) < _settingsCacheTtl;

    if (hasFreshCache) {
      return _settingsFromMap(cached.data, defaultInterval: defaultInterval);
    }

    try {
      final response = await _client
          .from('app_settings')
          .select('key,value')
          .inFilter('key', ['featured_slider_autoplay', 'featured_slider_interval_seconds']);

      final map = <String, String>{
        for (final row in (response as List<dynamic>))
          (row as Map<String, dynamic>)['key'] as String: ((row)['value'] as String? ?? ''),
      };

      await _cache.writeMap(cacheKey, map);
      return _settingsFromMap(map, defaultInterval: defaultInterval);
    } catch (_) {
      if (cached != null) {
        return _settingsFromMap(cached.data, defaultInterval: defaultInterval);
      }
      rethrow;
    }
  }

  FeaturedSliderSettingsModel _settingsFromMap(
    Map<String, dynamic> map, {
    required int defaultInterval,
  }) {
    final values = map.map((key, value) => MapEntry(key, value?.toString() ?? ''));

    final autoplay = (values['featured_slider_autoplay']?.toLowerCase() ?? 'true') == 'true';
    final interval = int.tryParse(values['featured_slider_interval_seconds'] ?? '$defaultInterval') ??
        defaultInterval;

    return FeaturedSliderSettingsModel(
      autoplay: autoplay,
      intervalSeconds: interval < 1 ? defaultInterval : interval,
    );
  }

  List<Map<String, dynamic>> _toMapList(dynamic response) {
    return (response as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
