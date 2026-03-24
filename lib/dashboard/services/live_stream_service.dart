import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/live_stream.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveStreamService {
  final _supabase = Supabase.instance.client;

  bool _isMissingLiveStreamColumn(Object error) {
    if (error is! PostgrestException) return false;
    final message = error.message.toLowerCase();
    return (message.contains('broadcast_title') ||
            message.contains('broadcast_title_en') ||
            message.contains('fallback_message_en')) &&
        (error.code?.toUpperCase() == 'PGRST204' ||
            message.contains("could not find"));
  }

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
      final data = Map<String, dynamic>.from(stream.toJson());
      if (stream.id.isEmpty) {
        data.remove('id');
        await _supabase.from('live_stream').insert(data);
      } else {
        await _supabase.from('live_stream').update(data).eq('id', stream.id);
      }
    } catch (e) {
      if (_isMissingLiveStreamColumn(e)) {
        final legacyData = Map<String, dynamic>.from(stream.toJson())
          ..remove('broadcast_title_en')
          ..remove('fallback_message_en')
          ..remove('broadcast_title')
          ..['title'] = stream.broadcastTitle;

        if (stream.id.isEmpty) {
          legacyData.remove('id');
          await _supabase.from('live_stream').insert(legacyData);
        } else {
          await _supabase
              .from('live_stream')
              .update(legacyData)
              .eq('id', stream.id);
        }
        return;
      }
      debugPrint('Error upserting live stream: $e');
      rethrow;
    }
  }
}
