import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/video_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideosService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  Future<List<VideoItem>> getVideos({
    String? programId,
    String? categoryId,
  }) async {
    try {
      var query = _supabase.from('videos').select();

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', _idValue(categoryId));
      } else if (programId != null && programId.isNotEmpty) {
        // Support legacy programId parameter for backward compatibility
        // In new model, programs are categories with type='program', so use programId as categoryId
        query = query.eq('category_id', _idValue(programId));
      }

      final response = await query.order('created_at', ascending: false);

      final mapped =
          (response as List<dynamic>)
              .map((json) => VideoItem.fromJson(json as Map<String, dynamic>))
              .toList();
      return mapped;
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      rethrow;
    }
  }

  Future<void> createVideo(VideoItem video) async {
    try {
      final data =
          Map<String, dynamic>.from(video.toJson())
            ..remove('id')
            ..remove('program_id');
      await _supabase.from('videos').insert(data);
    } catch (e) {
      debugPrint('Error creating video: $e');
      rethrow;
    }
  }

  Future<void> updateVideo(VideoItem video) async {
    try {
      final data =
          Map<String, dynamic>.from(video.toJson())
            ..remove('id')
            ..remove('program_id');
      await _supabase.from('videos').update(data).eq('id', _idValue(video.id));
    } catch (e) {
      debugPrint('Error updating video: $e');
      rethrow;
    }
  }

  Future<void> deleteVideo(String id) async {
    try {
      await _supabase.from('videos').delete().eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error deleting video: $e');
      rethrow;
    }
  }
}
