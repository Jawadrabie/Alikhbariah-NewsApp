part of 'home_repository.dart';

List<T>? _readCachedListSync<T>({
  required LocalCacheService cache,
  required String cacheKey,
  required List<T> Function(List<Map<String, dynamic>> rows) map,
}) {
  final cached = cache.readListSync(cacheKey);
  if (cached == null) return null;
  return _tryOrNull(() => map(cached.data));
}

T? _readCachedMapSync<T>({
  required LocalCacheService cache,
  required String cacheKey,
  required T Function(Map<String, dynamic> map) map,
}) {
  final cached = cache.readMapSync(cacheKey);
  if (cached == null) return null;
  return _tryOrNull(() => map(cached.data));
}

Future<List<T>> _loadCachedList<T>({
  required LocalCacheService cache,
  required String cacheKey,
  required Duration ttl,
  required bool forceRefresh,
  required Future<List<Map<String, dynamic>>> Function() fetch,
  required List<T> Function(List<Map<String, dynamic>> rows) map,
  Future<void> Function(List<Map<String, dynamic>> rows)? onFetched,
}) async {
  final cached = await cache.readList(cacheKey);

  if (_hasFreshCache(cached?.cachedAt, ttl, forceRefresh)) {
    return map(cached!.data);
  }

  try {
    final rows = await fetch();
    if (onFetched != null) {
      await onFetched(rows);
    }
    await cache.writeList(cacheKey, rows);
    return map(rows);
  } catch (_) {
    if (cached != null) {
      return map(cached.data);
    }
    rethrow;
  }
}

Future<T> _loadCachedMap<T>({
  required LocalCacheService cache,
  required String cacheKey,
  required Duration ttl,
  required bool forceRefresh,
  required Future<Map<String, dynamic>> Function() fetch,
  required T Function(Map<String, dynamic> map) map,
}) async {
  final cached = await cache.readMap(cacheKey);

  if (_hasFreshCache(cached?.cachedAt, ttl, forceRefresh)) {
    return map(cached!.data);
  }

  try {
    final data = await fetch();
    await cache.writeMap(cacheKey, data);
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

String get _categoriesCacheKey => 'home_categories';

String _featuredCacheKey(int limit) => 'home_featured_$limit';

String get _breakingCacheKey => 'home_breaking';

String get _featuredSliderSettingsCacheKey => 'home_featured_slider_settings';

String _latestNewsCacheKey({
  required int limit,
  required int offset,
  required int? categoryId,
  required String? searchQuery,
}) {
  return '${_latestNewsCachePrefix(categoryId: categoryId, searchQuery: searchQuery)}${offset}_$limit';
}

String _latestNewsCachePrefix({
  required int? categoryId,
  required String? searchQuery,
}) {
  return 'home_news_${categoryId ?? 'all'}_${_normalizeSearchQuery(searchQuery)}_';
}

Future<void> _clearSupersededLatestNewsPages({
  required LocalCacheService cache,
  required bool forceRefresh,
  required int offset,
  required int? categoryId,
  required String? searchQuery,
}) async {
  if (!forceRefresh || offset != 0) {
    return;
  }

  await cache.deleteByPrefix(
    _latestNewsCachePrefix(categoryId: categoryId, searchQuery: searchQuery),
  );
}

String _normalizeSearchQuery(String? searchQuery) {
  final query = searchQuery?.trim() ?? '';
  if (query.isEmpty) {
    return '';
  }

  return Uri.encodeComponent(query.toLowerCase());
}
