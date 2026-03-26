import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/local_cache_service.dart';
import '../models/breaking_news_headline_model.dart';
import '../models/category_model.dart';
import '../models/featured_slider_settings_model.dart';
import '../models/news_model.dart';

part 'home_repository_cache.dart';
part 'home_repository_mapping.dart';

const Duration _categoriesCacheTtl = Duration(hours: 6);
const Duration _newsCacheTtl = Duration(minutes: 10);
const Duration _featuredCacheTtl = Duration(minutes: 10);
const Duration _breakingCacheTtl = Duration(seconds: 30);
const Duration _settingsCacheTtl = Duration(hours: 1);
const int _defaultSliderIntervalSeconds = 3;

class HomeRepository {
  SupabaseClient get _client => Supabase.instance.client;
  final LocalCacheService _cache = LocalCacheService.instance;

  List<CategoryModel>? getCachedCategories({String languageCode = 'ar'}) {
    return _readCachedListSync(
      cache: _cache,
      cacheKey: _categoriesCacheKey,
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
      cache: _cache,
      cacheKey: _latestNewsCacheKey(
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
      cache: _cache,
      cacheKey: _featuredCacheKey(limit),
      map: (rows) => _mapNews(rows, languageCode: languageCode),
    );
  }

  List<String>? getCachedBreakingNewsTitles({String languageCode = 'ar'}) {
    final normalizedLanguage = languageCode.toLowerCase();
    return _readCachedListSync(
      cache: _cache,
      cacheKey: _breakingCacheKey,
      map: (rows) => _mapBreakingTitles(rows, languageCode: normalizedLanguage),
    );
  }

  List<BreakingNewsHeadlineModel>? getCachedActiveBreakingNewsHeadlines({
    String languageCode = 'ar',
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    return _readCachedListSync(
      cache: _cache,
      cacheKey: _breakingCacheKey,
      map:
          (rows) =>
              _mapBreakingHeadlines(rows, languageCode: normalizedLanguage),
    );
  }

  FeaturedSliderSettingsModel? getCachedFeaturedSliderSettings() {
    return _readCachedMapSync(
      cache: _cache,
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
      cache: _cache,
      cacheKey: _categoriesCacheKey,
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
      cache: _cache,
      cacheKey: _latestNewsCacheKey(
        limit: limit,
        offset: offset,
        categoryId: categoryId,
        searchQuery: searchQuery,
      ),
      ttl: _newsCacheTtl,
      forceRefresh: forceRefresh,
      fetch: () async {
        PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
            _newsBaseQuery(_client);

        if (categoryId != null) {
          query = query.eq('category_id', categoryId);
        }

        final normalizedSearch = searchQuery?.trim();
        if (normalizedSearch != null && normalizedSearch.isNotEmpty) {
          final safeSearch = _sanitizeSearchTerm(normalizedSearch);
          if (safeSearch.isNotEmpty) {
            final pattern = '%$safeSearch%';
            query = query.or(
              'title.ilike.$pattern,title_en.ilike.$pattern,content.ilike.$pattern,content_en.ilike.$pattern',
            );
          }
        }

        final response = await query
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);
        return _toMapList(response);
      },
      map: (rows) => _mapNews(rows, languageCode: languageCode),
      onFetched:
          (_) => _clearSupersededLatestNewsPages(
            cache: _cache,
            forceRefresh: forceRefresh,
            offset: offset,
            categoryId: categoryId,
            searchQuery: searchQuery,
          ),
    );
  }

  Future<List<NewsModel>> getFeaturedNews({
    String languageCode = 'ar',
    int limit = 5,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _featuredCacheKey(limit);
    final cached = await _cache.readList(cacheKey);

    if (_hasFreshCache(cached?.cachedAt, _featuredCacheTtl, forceRefresh)) {
      return _mapNews(cached!.data, languageCode: languageCode);
    }

    try {
      final response = await _newsBaseQuery(
        _client,
      ).eq('is_featured', true).limit(limit);
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
      cache: _cache,
      cacheKey: _breakingCacheKey,
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
      cache: _cache,
      cacheKey: _breakingCacheKey,
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
      cache: _cache,
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
}
