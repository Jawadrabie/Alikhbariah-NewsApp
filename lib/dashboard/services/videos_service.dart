import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/video_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideosService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  Future<List<VideoItem>> getVideos({String? programId}) async {
    try {
      final response = await _supabase
          .from('videos')
          .select()
          .order('created_at', ascending: false);

      final mapped = (response as List<dynamic>)
          .map((json) => VideoItem.fromJson(json as Map<String, dynamic>))
          .toList();
      if (programId == null || programId.isEmpty) {
        return mapped;
      }
      return mapped.where((item) => item.programId == programId).toList();
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      rethrow;
    }
  }

  Future<void> createVideo(VideoItem video) async {
    try {
      final data = Map<String, dynamic>.from(video.toJson())..remove('id');
      await _supabase.from('videos').insert(data);
    } catch (e) {
      debugPrint('Error creating video: $e');
      rethrow;
    }
  }

  Future<void> updateVideo(VideoItem video) async {
    try {
      final data = Map<String, dynamic>.from(video.toJson())..remove('id');
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
