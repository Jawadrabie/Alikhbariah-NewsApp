import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/local_cache_service.dart';
import '../models/live_stream_model.dart';
import '../models/video_category_model.dart';
import '../models/video_item_model.dart';

class MediaRepository {
  SupabaseClient get _client => Supabase.instance.client;
  final LocalCacheService _cache = LocalCacheService.instance;

  static const Duration _videoCategoriesCacheTtl = Duration(hours: 2);
  static const Duration _videosCacheTtl = Duration(minutes: 15);
  static const Duration _liveCacheTtl = Duration(minutes: 2);

  // --- Synchronous Getters ---

  List<VideoCategoryModel>? getCachedVideoCategories({
    String languageCode = 'ar',
    String categoryType = 'video',
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    final cacheKey = 'media_${categoryType}_categories';
    final cached = _cache.readListSync(cacheKey);
    if (cached != null) {
      return cached.data
          .map(
            (e) => VideoCategoryModel.fromJson(
              e,
              languageCode: normalizedLanguage,
            ),
          )
          .toList();
    }
    return null;
  }

  List<VideoItemModel>? getCachedVideos({
    String languageCode = 'ar',
    int? programId,
    int? categoryId,
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    final effectiveCategoryId = categoryId ?? programId;
    final cacheKey = 'media_videos_${effectiveCategoryId ?? 'all'}';
    final cached = _cache.readListSync(cacheKey);
    if (cached != null) {
      return cached.data
          .map(
            (e) => VideoItemModel.fromJson(e, languageCode: normalizedLanguage),
          )
          .toList();
    }
    return null;
  }

  // --- End Synchronous Getters ---

  LiveStreamModel? getCachedActiveLiveStream({String languageCode = 'ar'}) {
    final normalizedLanguage = languageCode.toLowerCase();
    final cached = _cache.readMapSync('media_live_stream');
    if (cached == null || cached.data['has_data'] != true) {
      return null;
    }

    final row = cached.data['row'];
    if (row is! Map) {
      return null;
    }

    return LiveStreamModel.fromJson(
      Map<String, dynamic>.from(row),
      languageCode: normalizedLanguage,
    );
  }

  Future<List<VideoCategoryModel>> getVideoCategories({
    String languageCode = 'ar',
    String categoryType = 'video',
    bool forceRefresh = false,
  }) async {
    final normalizedLanguage = languageCode.toLowerCase();
    final cacheKey = 'media_${categoryType}_categories';
    final cached = await _cache.readList(cacheKey);
    final hasFreshCache =
        !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _videoCategoriesCacheTtl;
    if (hasFreshCache) {
      return cached.data
          .map(
            (row) => VideoCategoryModel.fromJson(
              row,
              languageCode: normalizedLanguage,
            ),
          )
          .toList();
    }

    try {
      dynamic response;
      try {
        response = await _client
            .from('categories')
            .select('id,name,name_en,slug,cover_image_url,order_index')
            .eq('type', categoryType)
            .order('order_index', ascending: true);
      } catch (e) {
        final text = e.toString();
        final missingCoverColumn =
            text.contains('cover_image_url') && text.contains('42703');
        if (!missingCoverColumn) rethrow;

        response = await _client
            .from('categories')
            .select('id,name,name_en,slug,order_index')
            .eq('type', categoryType)
            .order('order_index', ascending: true);
      }

      final rows = _toMapList(response);
      await _cache.writeList(cacheKey, rows);
      return rows
          .map(
            (row) => VideoCategoryModel.fromJson(
              row,
              languageCode: normalizedLanguage,
            ),
          )
          .toList();
    } catch (_) {
      if (cached != null) {
        return cached.data
            .map(
              (row) => VideoCategoryModel.fromJson(
                row,
                languageCode: normalizedLanguage,
              ),
            )
            .toList();
      }
      rethrow;
    }
  }

  Future<List<VideoItemModel>> getVideos({
    String languageCode = 'ar',
    int? programId,
    int? categoryId,
    bool forceRefresh = false,
  }) async {
    final effectiveCategoryId = categoryId ?? programId;
    final normalizedLanguage = languageCode.toLowerCase();
    final cacheKey = 'media_videos_${effectiveCategoryId ?? 'all'}';
    final cached = await _cache.readList(cacheKey);
    final hasFreshCache =
        !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _videosCacheTtl;
    if (hasFreshCache) {
      return cached.data
          .map(
            (row) =>
                VideoItemModel.fromJson(row, languageCode: normalizedLanguage),
          )
          .toList();
    }

    dynamic query = _client
        .from('videos')
        .select(
          'id,title,title_en,youtube_url,category_id,thumbnail_url,published_at,created_at',
        )
        .eq('is_hidden', false);

    if (effectiveCategoryId != null) {
      query = query.eq('category_id', effectiveCategoryId);
    }

    try {
      final response = await query
          .order('published_at', ascending: false)
          .order('created_at', ascending: false);

      final rows = _toMapList(response);
      await _cache.writeList(cacheKey, rows);
      return rows
          .map(
            (row) =>
                VideoItemModel.fromJson(row, languageCode: normalizedLanguage),
          )
          .toList();
    } catch (_) {
      if (cached != null) {
        return cached.data
            .map(
              (row) => VideoItemModel.fromJson(
                row,
                languageCode: normalizedLanguage,
              ),
            )
            .toList();
      }
      rethrow;
    }
  }

  Future<LiveStreamModel?> getActiveLiveStream({
    String languageCode = 'ar',
    bool forceRefresh = false,
  }) async {
    final normalizedLanguage = languageCode.toLowerCase();
    final cacheKey = 'media_live_stream';
    final cached = await _cache.readMap(cacheKey);
    final hasFreshCache =
        !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _liveCacheTtl;
    if (hasFreshCache) {
      final cachedData = cached.data;
      if (cachedData['has_data'] != true) {
        return null;
      }
      final row = cachedData['row'];
      if (row is Map) {
        return LiveStreamModel.fromJson(
          Map<String, dynamic>.from(row),
          languageCode: normalizedLanguage,
        );
      }
    }

    try {
      final response = await _client
          .from('live_stream')
          .select()
          .eq('is_active', true)
          .order('id', ascending: false)
          .limit(1);

      final rows = _toMapList(response);
      if (rows.isEmpty) {
        await _cache.writeMap(cacheKey, {'has_data': false, 'row': null});
        return null;
      }

      final row = rows.first;
      await _cache.writeMap(cacheKey, {'has_data': true, 'row': row});
      return LiveStreamModel.fromJson(row, languageCode: normalizedLanguage);
    } catch (_) {
      if (cached != null) {
        final cachedData = cached.data;
        if (cachedData['has_data'] != true) {
          return null;
        }
        final row = cachedData['row'];
        if (row is Map) {
          return LiveStreamModel.fromJson(
            Map<String, dynamic>.from(row),
            languageCode: normalizedLanguage,
          );
        }
      }
      rethrow;
    }
  }

  List<Map<String, dynamic>> _toMapList(dynamic response) {
    return (response as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
