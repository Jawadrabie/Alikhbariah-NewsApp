import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/live_stream.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveStreamService {
  final _supabase = Supabase.instance.client;

  Future<LiveStream?> getLiveStream() async {
    try {
      final response = await _supabase.from('live_stream').select().limit(1);
      final data = response as List<dynamic>;
      if (data.isEmpty) {
        return null;
      }
      return LiveStream.fromJson(data.first as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error fetching live stream: $e');
      rethrow;
    }
  }

  Future<void> upsertLiveStream(LiveStream stream) async {
    try {
      await _supabase.from('live_stream').upsert(stream.toJson());
    } catch (e) {
      debugPrint('Error upserting live stream: $e');
      rethrow;
    }
  }
}
