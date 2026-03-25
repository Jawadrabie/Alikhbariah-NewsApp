import 'dart:convert';

import 'package:hive/hive.dart';

typedef CachedListEntry =
    ({DateTime cachedAt, List<Map<String, dynamic>> data});
typedef CachedMapEntry = ({DateTime cachedAt, Map<String, dynamic> data});

class LocalCacheService {
  LocalCacheService._();

  static final LocalCacheService instance = LocalCacheService._();
  static const String _boxName = 'app_cache_v1';
  Box<String>? _box;

  final Map<String, ({DateTime cachedAt, Object data})> _memoryCache =
      <String, ({DateTime cachedAt, Object data})>{};

  /// Initialize the cache service synchronously (pre-loading is optional but box needs to be open)
  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<Box<String>> _openBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(_boxName);
    return _box!;
  }

  /// Synchronous read for initial state
  CachedListEntry? readListSync(String key) {
    try {
      if (_box == null || !_box!.isOpen) return null;

      // 1. Check memory
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null && memoryEntry.data is List) {
        final memoryRows =
            (memoryEntry.data as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
        return (cachedAt: memoryEntry.cachedAt, data: memoryRows);
      }

      // 2. Check Hive sync
      final raw = _box!.get(key);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final cachedAtRaw = decoded['cached_at'] as String?;
      if (cachedAtRaw == null) return null;
      final cachedAt = DateTime.tryParse(cachedAtRaw);
      if (cachedAt == null) return null;

      final data = decoded['data'];
      if (data is! List) return null;

      final rows =
          data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

      // Update memory cache
      _memoryCache[key] = (cachedAt: cachedAt, data: rows);

      return (cachedAt: cachedAt, data: rows);
    } catch (_) {
      return null;
    }
  }

  /// Synchronous read for initial state
  CachedMapEntry? readMapSync(String key) {
    try {
      if (_box == null || !_box!.isOpen) return null;

      // 1. Check memory
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null && memoryEntry.data is Map) {
        return (
          cachedAt: memoryEntry.cachedAt,
          data: Map<String, dynamic>.from(memoryEntry.data as Map),
        );
      }

      // 2. Check Hive sync
      final raw = _box!.get(key);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final cachedAtRaw = decoded['cached_at'] as String?;
      if (cachedAtRaw == null) return null;
      final cachedAt = DateTime.tryParse(cachedAtRaw);
      if (cachedAt == null) return null;

      final data = decoded['data'];
      if (data is! Map) return null;

      final mapData = Map<String, dynamic>.from(data);

      // Update memory cache
      _memoryCache[key] = (cachedAt: cachedAt, data: mapData);

      return (cachedAt: cachedAt, data: mapData);
    } catch (_) {
      return null;
    }
  }

  Future<CachedListEntry?> readList(String key) async {
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && memoryEntry.data is List) {
      final memoryRows =
          (memoryEntry.data as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
      return (cachedAt: memoryEntry.cachedAt, data: memoryRows);
    }

    final entry = await _readEntry(key);
    if (entry == null) return null;

    final data = entry.data['data'];
    if (data is! List) return null;

    final rows =
        data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

    _memoryCache[key] = (cachedAt: entry.cachedAt, data: rows);

    return (cachedAt: entry.cachedAt, data: rows);
  }

  Future<CachedMapEntry?> readMap(String key) async {
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && memoryEntry.data is Map) {
      return (
        cachedAt: memoryEntry.cachedAt,
        data: Map<String, dynamic>.from(memoryEntry.data as Map),
      );
    }

    final entry = await _readEntry(key);
    if (entry == null) return null;

    final data = entry.data['data'];
    if (data is! Map) return null;

    final mapData = Map<String, dynamic>.from(data);
    _memoryCache[key] = (cachedAt: entry.cachedAt, data: mapData);

    return (cachedAt: entry.cachedAt, data: mapData);
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> data) async {
    await _writeEntry(key, data);
  }

  Future<void> writeMap(String key, Map<String, dynamic> data) async {
    await _writeEntry(key, data);
  }

  Future<void> delete(String key) async {
    final box = await _openBox();
    _memoryCache.remove(key);
    await box.delete(key);
  }

  Future<void> _writeEntry(String key, Object data) async {
    final box = await _openBox();
    final cachedAt = DateTime.now();
    final payload = <String, dynamic>{
      'cached_at': cachedAt.toIso8601String(),
      'data': data,
    };
    _memoryCache[key] = (cachedAt: cachedAt, data: data);
    await box.put(key, jsonEncode(payload));
  }

  Future<({DateTime cachedAt, Map<String, dynamic> data})?> _readEntry(
    String key,
  ) async {
    final box = await _openBox();
    final raw = box.get(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final cachedAtRaw = decoded['cached_at'] as String?;
      if (cachedAtRaw == null) return null;
      final cachedAt = DateTime.tryParse(cachedAtRaw);
      if (cachedAt == null) return null;

      return (cachedAt: cachedAt, data: decoded);
    } catch (_) {
      return null;
    }
  }
}
