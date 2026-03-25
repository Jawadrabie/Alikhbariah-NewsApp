import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/local_cache_service.dart';
import '../models/breaking_news_headline_model.dart';
import '../models/category_model.dart';
import '../models/featured_slider_settings_model.dart';
import '../models/news_model.dart';

class HomeRepository {
  static const Duration _categoriesCacheTtl = Duration(hours: 6);
  static const Duration _newsCacheTtl = Duration(minutes: 10);
  static const Duration _featuredCacheTtl = Duration(minutes: 10);
  static const Duration _breakingCacheTtl = Duration(seconds: 30);
  static const Duration _settingsCacheTtl = Duration(hours: 1);
  static const int _defaultSliderIntervalSeconds = 3;

  SupabaseClient get _client => Supabase.instance.client;
  final LocalCacheService _cache = LocalCacheService.instance;

  List<CategoryModel>? getCachedCategories({String languageCode = 'ar'}) {
    return _readCachedListSync(
      cacheKey: _categoriesCacheKey(languageCode),
      map: (rows) => _mapCategories(rows, languageCode: languageCode),
    );
  }

  List<NewsModel>? getCachedLatestNews({
    String languageCode = 'ar',
    int limit = 20,
    int offset = 0,
    int? categoryId,
    String? searchQuery,
  }) {
    return _readCachedListSync(
      cacheKey: _latestNewsCacheKey(
        languageCode: languageCode,
        limit: limit,
        offset: offset,
        categoryId: categoryId,
        searchQuery: searchQuery,
      ),
      map: (rows) => _mapNews(rows, languageCode: languageCode),
    );
  }

  List<NewsModel>? getCachedFeaturedNews({
    String languageCode = 'ar',
    int limit = 5,
  }) {
    return _readCachedListSync(
      cacheKey: _featuredCacheKey(languageCode, limit),
      map: (rows) => _mapNews(rows, languageCode: languageCode),
    );
  }

  List<String>? getCachedBreakingNewsTitles({String languageCode = 'ar'}) {
    final normalizedLanguage = languageCode.toLowerCase();
    return _readCachedListSync(
      cacheKey: _breakingCacheKey(normalizedLanguage),
      map: (rows) => _mapBreakingTitles(rows, languageCode: normalizedLanguage),
    );
  }

  List<BreakingNewsHeadlineModel>? getCachedActiveBreakingNewsHeadlines({
    String languageCode = 'ar',
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    return _readCachedListSync(
      cacheKey: _breakingCacheKey(normalizedLanguage),
      map:
          (rows) =>
              _mapBreakingHeadlines(rows, languageCode: normalizedLanguage),
    );
  }

  FeaturedSliderSettingsModel? getCachedFeaturedSliderSettings() {
    return _readCachedMapSync(
      cacheKey: _featuredSliderSettingsCacheKey,
      map:
          (map) => _settingsFromMap(
            map,
            defaultInterval: _defaultSliderIntervalSeconds,
          ),
    );
  }

  Future<List<CategoryModel>> getCategories({
    String languageCode = 'ar',
    bool forceRefresh = false,
  }) {
    return _loadCachedList(
      cacheKey: _categoriesCacheKey(languageCode),
      ttl: _categoriesCacheTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        final response = await _client
            .from('categories')
            .select('*')
            .eq('type', 'news')
            .order('order_index', ascending: true);
        return _toMapList(response);
      },
      map: (rows) => _mapCategories(rows, languageCode: languageCode),
    );
  }

  Future<List<NewsModel>> getLatestNews({
    String languageCode = 'ar',
    int limit = 20,
    int offset = 0,
    int? categoryId,
    String? searchQuery,
    bool forceRefresh = false,
  }) {
    return _loadCachedList(
      cacheKey: _latestNewsCacheKey(
        languageCode: languageCode,
        limit: limit,
        offset: offset,
        categoryId: categoryId,
        searchQuery: searchQuery,
      ),
      ttl: _newsCacheTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
            _newsBaseQuery();

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

        final response = await query
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
        return _toMapList(response);
      },
      map: (rows) => _mapNews(rows, languageCode: languageCode),
    );
  }

  Future<List<NewsModel>> getFeaturedNews({
    String languageCode = 'ar',
    int limit = 5,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _featuredCacheKey(languageCode, limit);
    final cached = await _cache.readList(cacheKey);

    if (_hasFreshCache(cached?.cachedAt, _featuredCacheTtl, forceRefresh)) {
      return _mapNews(cached!.data, languageCode: languageCode);
    }

    try {
      final response = await _newsBaseQuery()
          .eq('is_featured', true)
          .limit(limit);
      final featuredRows = _toMapList(response);
      final featured = _mapNews(featuredRows, languageCode: languageCode);

      if (featured.isNotEmpty) {
        await _cache.writeList(cacheKey, featuredRows);
        return featured;
      }

      return getLatestNews(
        languageCode: languageCode,
        limit: limit,
        offset: 0,
        forceRefresh: forceRefresh,
      );
    } catch (_) {
      if (cached != null) {
        return _mapNews(cached.data, languageCode: languageCode);
      }
      rethrow;
    }
  }

  Future<void> incrementNewsViewCount(int newsId) async {
    await _client.rpc(
      'increment_news_view_count',
      params: {'p_news_id': newsId},
    );
  }

  Future<List<String>> getActiveBreakingNewsTitles({
    String languageCode = 'ar',
    bool forceRefresh = false,
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    return _loadCachedList(
      cacheKey: _breakingCacheKey(normalizedLanguage),
      ttl: _breakingCacheTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        final nowIso = DateTime.now().toIso8601String();
        final response = await _client
            .from('breaking_news')
            .select('*')
            .eq('is_active', true)
            .lte('start_time', nowIso)
            .gte('end_time', nowIso)
            .order('created_at', ascending: false);
        return _toMapList(response);
      },
      map: (rows) => _mapBreakingTitles(rows, languageCode: normalizedLanguage),
    );
  }

  Future<List<BreakingNewsHeadlineModel>> getActiveBreakingNewsHeadlines({
    String languageCode = 'ar',
    bool forceRefresh = false,
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    return _loadCachedList(
      cacheKey: _breakingCacheKey(normalizedLanguage),
      ttl: _breakingCacheTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        final nowIso = DateTime.now().toIso8601String();
        final response = await _client
            .from('breaking_news')
            .select('*')
            .eq('is_active', true)
            .lte('start_time', nowIso)
            .gte('end_time', nowIso)
            .order('created_at', ascending: false);
        return _toMapList(response);
      },
      map:
          (rows) =>
              _mapBreakingHeadlines(rows, languageCode: normalizedLanguage),
    );
  }

  Future<void> incrementBreakingNewsViewCount(int breakingNewsId) async {
    await _client.rpc(
      'increment_breaking_news_view_count',
      params: {'p_breaking_news_id': breakingNewsId},
    );
  }

  Future<FeaturedSliderSettingsModel> getFeaturedSliderSettings({
    bool forceRefresh = false,
  }) {
    return _loadCachedMap(
      cacheKey: _featuredSliderSettingsCacheKey,
      ttl: _settingsCacheTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        final response = await _client
            .from('app_settings')
            .select('key,value')
            .inFilter('key', [
              'featured_slider_autoplay',
              'featured_slider_interval_seconds',
            ]);

        return {
          for (final row in (response as List<dynamic>))
            (row as Map<String, dynamic>)['key'] as String:
                row['value'] as String? ?? '',
        };
      },
      map:
          (map) => _settingsFromMap(
            map,
            defaultInterval: _defaultSliderIntervalSeconds,
          ),
    );
  }

  List<T>? _readCachedListSync<T>({
    required String cacheKey,
    required List<T> Function(List<Map<String, dynamic>> rows) map,
  }) {
    final cached = _cache.readListSync(cacheKey);
    if (cached == null) return null;
    return _tryOrNull(() => map(cached.data));
  }

  T? _readCachedMapSync<T>({
    required String cacheKey,
    required T Function(Map<String, dynamic> map) map,
  }) {
    final cached = _cache.readMapSync(cacheKey);
    if (cached == null) return null;
    return _tryOrNull(() => map(cached.data));
  }

  Future<List<T>> _loadCachedList<T>({
    required String cacheKey,
    required Duration ttl,
    required bool forceRefresh,
    required Future<List<Map<String, dynamic>>> Function() fetch,
    required List<T> Function(List<Map<String, dynamic>> rows) map,
  }) async {
    final cached = await _cache.readList(cacheKey);

    if (_hasFreshCache(cached?.cachedAt, ttl, forceRefresh)) {
      return map(cached!.data);
    }

    try {
      final rows = await fetch();
      await _cache.writeList(cacheKey, rows);
      return map(rows);
    } catch (_) {
      if (cached != null) {
        return map(cached.data);
      }
      rethrow;
    }
  }

  Future<T> _loadCachedMap<T>({
    required String cacheKey,
    required Duration ttl,
    required bool forceRefresh,
    required Future<Map<String, dynamic>> Function() fetch,
    required T Function(Map<String, dynamic> map) map,
  }) async {
    final cached = await _cache.readMap(cacheKey);

    if (_hasFreshCache(cached?.cachedAt, ttl, forceRefresh)) {
      return map(cached!.data);
    }

    try {
      final data = await fetch();
      await _cache.writeMap(cacheKey, data);
      return map(data);
    } catch (_) {
      if (cached != null) {
        return map(cached.data);
      }
      rethrow;
    }
  }

  bool _hasFreshCache(DateTime? cachedAt, Duration ttl, bool forceRefresh) {
    return !forceRefresh &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < ttl;
  }

  T? _tryOrNull<T>(T Function() action) {
    try {
      return action();
    } catch (_) {
      return null;
    }
  }

  List<CategoryModel> _mapCategories(
    List<Map<String, dynamic>> rows, {
    required String languageCode,
  }) {
    return rows
        .map((item) => CategoryModel.fromJson(item, languageCode: languageCode))
        .toList();
  }

  List<NewsModel> _mapNews(
    List<Map<String, dynamic>> rows, {
    required String languageCode,
  }) {
    return rows
        .map((item) => NewsModel.fromJson(item, languageCode: languageCode))
        .toList();
  }

  List<String> _mapBreakingTitles(
    List<Map<String, dynamic>> rows, {
    required String languageCode,
  }) {
    final fallbackLanguage = languageCode == 'en' ? 'ar' : 'en';

    return rows
        .map(
          (item) =>
              _readText(item['title_$languageCode']) ??
              _readText(item['title']) ??
              _readText(item['title_$fallbackLanguage']) ??
              '',
        )
        .where((title) => title.trim().isNotEmpty)
        .toList();
  }

  List<BreakingNewsHeadlineModel> _mapBreakingHeadlines(
    List<Map<String, dynamic>> rows, {
    required String languageCode,
  }) {
    final fallbackLanguage = languageCode == 'en' ? 'ar' : 'en';

    return rows
        .map((item) {
          final id = (item['id'] as num?)?.toInt();
          final title =
              _readText(item['title_$languageCode']) ??
              _readText(item['title']) ??
              _readText(item['title_$fallbackLanguage']) ??
              '';

          if (id == null || title.trim().isEmpty) {
            return null;
          }

          return BreakingNewsHeadlineModel(id: id, title: title);
        })
        .whereType<BreakingNewsHeadlineModel>()
        .toList();
  }

  PostgrestFilterBuilder<List<Map<String, dynamic>>> _newsBaseQuery() {
    return _client.from('news').select('*').eq('is_hidden', false);
  }

  String _categoriesCacheKey(String languageCode) {
    return 'home_categories_${languageCode.toLowerCase()}';
  }

  String _featuredCacheKey(String languageCode, int limit) {
    return 'home_featured_${languageCode.toLowerCase()}_$limit';
  }

  String _breakingCacheKey(String languageCode) {
    return 'home_breaking_$languageCode';
  }

  String get _featuredSliderSettingsCacheKey => 'home_featured_slider_settings';

  String _latestNewsCacheKey({
    required String languageCode,
    required int limit,
    required int offset,
    required int? categoryId,
    required String? searchQuery,
  }) {
    final query = searchQuery?.trim() ?? '';
    final normalizedQuery =
        query.isEmpty ? '' : Uri.encodeComponent(query.toLowerCase());

    return 'home_news_${languageCode.toLowerCase()}_${categoryId ?? 'all'}_${offset}_${limit}_$normalizedQuery';
  }

  String _sanitizeSearchTerm(String value) {
    return value
        .replaceAll(',', ' ')
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .trim();
  }

  String? _readText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  FeaturedSliderSettingsModel _settingsFromMap(
    Map<String, dynamic> map, {
    required int defaultInterval,
  }) {
    final values = map.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );

    final autoplay =
        (values['featured_slider_autoplay']?.toLowerCase() ?? 'true') == 'true';
    final interval =
        int.tryParse(
          values['featured_slider_interval_seconds'] ?? '$defaultInterval',
        ) ??
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
