import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/local_cache_service.dart';
import '../models/live_stream_model.dart';
import '../models/program_model.dart';
import '../models/video_category_model.dart';
import '../models/video_item_model.dart';

class MediaRepository {
  SupabaseClient get _client => Supabase.instance.client;
  final LocalCacheService _cache = LocalCacheService.instance;

  static const Duration _programsCacheTtl = Duration(hours: 2);
  static const Duration _videoCategoriesCacheTtl = Duration(hours: 2);
  static const Duration _videosCacheTtl = Duration(minutes: 15);
  static const Duration _liveCacheTtl = Duration(minutes: 2);

  // --- Synchronous Getters ---

  List<ProgramModel>? getCachedPrograms() {
    const cacheKey = 'media_programs';
    final cached = _cache.readListSync(cacheKey);
    if (cached != null) {
      return cached.data.map(ProgramModel.fromJson).toList();
    }
    return null;
  }

  List<VideoCategoryModel>? getCachedVideoCategories() {
    const cacheKey = 'media_video_categories';
    final cached = _cache.readListSync(cacheKey);
    if (cached != null) {
      return cached.data.map((e) => VideoCategoryModel.fromJson(e)).toList();
    }
    return null;
  }

  List<VideoItemModel>? getCachedVideos({int? programId, int? categoryId}) {
    final cacheKey = 'media_videos_${programId ?? 'all'}_${categoryId ?? 'all'}';
    final cached = _cache.readListSync(cacheKey);
    if (cached != null) {
      return cached.data.map((e) => VideoItemModel.fromJson(e)).toList();
    }
    return null;
  }

  // --- End Synchronous Getters ---

  Future<List<ProgramModel>> getPrograms({bool forceRefresh = false}) async {
    const cacheKey = 'media_programs';
    final cached = await _cache.readList(cacheKey);
    final hasFreshCache = !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _programsCacheTtl;
    if (hasFreshCache) {
      return cached.data.map(ProgramModel.fromJson).toList();
    }

    try {
      final response = await _client
          .from('programs')
          .select('id,name,description,image_url,order_index')
          .eq('is_active', true)
          .order('order_index', ascending: true)
          .order('created_at', ascending: false);

      final rows = _toMapList(response);
      await _cache.writeList(cacheKey, rows);
      return rows.map(ProgramModel.fromJson).toList();
    } catch (_) {
      if (cached != null) {
        return cached.data.map(ProgramModel.fromJson).toList();
      }
      rethrow;
    }
  }

  Future<List<VideoCategoryModel>> getVideoCategories({bool forceRefresh = false}) async {
    const cacheKey = 'media_video_categories';
    final cached = await _cache.readList(cacheKey);
    final hasFreshCache = !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _videoCategoriesCacheTtl;
    if (hasFreshCache) {
      return cached.data.map(VideoCategoryModel.fromJson).toList();
    }

    try {
      final response = await _client
          .from('categories')
          .select('id,name,slug,order_index')
          .eq('type', 'video')
          .order('order_index', ascending: true);

      final rows = _toMapList(response);
      await _cache.writeList(cacheKey, rows);
      return rows.map(VideoCategoryModel.fromJson).toList();
    } catch (_) {
      if (cached != null) {
        return cached.data.map(VideoCategoryModel.fromJson).toList();
      }
      rethrow;
    }
  }

  Future<List<VideoItemModel>> getVideos({
    int? programId,
    int? categoryId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'media_videos_${programId ?? 'all'}_${categoryId ?? 'all'}';
    final cached = await _cache.readList(cacheKey);
    final hasFreshCache = !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _videosCacheTtl;
    if (hasFreshCache) {
      return cached.data.map(VideoItemModel.fromJson).toList();
    }

    final query = _client
        .from('videos')
        .select('id,title,youtube_url,program_id,category_id,thumbnail_url,published_at,created_at')
        .eq('is_hidden', false);

    if (programId != null) {
      query.eq('program_id', programId);
    }
    if (categoryId != null) {
      query.eq('category_id', categoryId);
    }

    try {
      final response = await query
          .order('published_at', ascending: false)
          .order('created_at', ascending: false);

      final rows = _toMapList(response);
      await _cache.writeList(cacheKey, rows);
      return rows.map(VideoItemModel.fromJson).toList();
    } catch (_) {
      if (cached != null) {
        return cached.data.map(VideoItemModel.fromJson).toList();
      }
      rethrow;
    }
  }

  Future<LiveStreamModel?> getActiveLiveStream({bool forceRefresh = false}) async {
    const cacheKey = 'media_live_stream';
    final cached = await _cache.readMap(cacheKey);
    final hasFreshCache = !forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.cachedAt) < _liveCacheTtl;
    if (hasFreshCache) {
      final cachedData = cached.data;
      if (cachedData['has_data'] != true) {
        return null;
      }
      final row = cachedData['row'];
      if (row is Map) {
        return LiveStreamModel.fromJson(Map<String, dynamic>.from(row));
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
      return LiveStreamModel.fromJson(row);
    } catch (_) {
      if (cached != null) {
        final cachedData = cached.data;
        if (cachedData['has_data'] != true) {
          return null;
        }
        final row = cachedData['row'];
        if (row is Map) {
          return LiveStreamModel.fromJson(Map<String, dynamic>.from(row));
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
