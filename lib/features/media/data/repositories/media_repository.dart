import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/live_stream_model.dart';
import '../models/program_model.dart';
import '../models/video_item_model.dart';

class MediaRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<ProgramModel>> getPrograms() async {
    final response = await _client
        .from('programs')
        .select('id,name,description,image_url,order_index')
        .eq('is_active', true)
        .order('order_index', ascending: true)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => ProgramModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoItemModel>> getVideos({int? programId}) async {
    final query = _client
        .from('videos')
        .select('id,title,youtube_url,thumbnail_url,published_at,created_at')
        .eq('is_hidden', false);

    if (programId != null) {
      query.eq('program_id', programId);
    }

    final response = await query
        .order('published_at', ascending: false)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => VideoItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<LiveStreamModel?> getActiveLiveStream() async {
    final response = await _client
        .from('live_stream')
        .select('id,youtube_url,is_active,broadcast_title,fallback_message')
        .eq('is_active', true)
        .order('id', ascending: false)
        .limit(1);

    final rows = response as List<dynamic>;
    if (rows.isEmpty) {
      return null;
    }

    return LiveStreamModel.fromJson(rows.first as Map<String, dynamic>);
  }
}
