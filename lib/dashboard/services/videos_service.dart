import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/video_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideosService {
  final _supabase = Supabase.instance.client;

  Future<List<VideoItem>> getVideos({String? programId}) async {
    try {
      var query = _supabase
          .from('videos')
          .select()
          .order('created_at', ascending: false);

      if (programId != null && programId.isNotEmpty) {
        query = query.eq('program_id', programId);
      }

      final response = await query;
      return (response as List<dynamic>)
          .map((json) => VideoItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      rethrow;
    }
  }

  Future<void> createVideo(VideoItem video) async {
    try {
      await _supabase.from('videos').insert(video.toJson());
    } catch (e) {
      debugPrint('Error creating video: $e');
      rethrow;
    }
  }

  Future<void> updateVideo(VideoItem video) async {
    try {
      await _supabase.from('videos').update(video.toJson()).eq('id', video.id);
    } catch (e) {
      debugPrint('Error updating video: $e');
      rethrow;
    }
  }

  Future<void> deleteVideo(String id) async {
    try {
      await _supabase.from('videos').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting video: $e');
      rethrow;
    }
  }
}
