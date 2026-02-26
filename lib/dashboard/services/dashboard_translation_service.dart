import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardTranslationService {
  DashboardTranslationService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  final Map<String, String> _cache = <String, String>{};

  Future<String> translateArToEn(String text) async {
    final source = text.trim();
    if (source.isEmpty) return '';

    final cacheKey = 'ar:en:$source';
    final cached = _cache[cacheKey];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final response = await _client.functions.invoke(
        'translate-text',
        body: {
          'text': source,
          'source': 'ar',
          'target': 'en',
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final translated = data['translatedText']?.toString().trim() ?? '';
        if (translated.isNotEmpty) {
          _cache[cacheKey] = translated;
          return translated;
        }
      }
    } catch (error) {
      debugPrint('Translation skipped: $error');
    }

    return source;
  }

  Future<Map<String, String>> translateNewsFields({
    required String title,
    required String content,
  }) async {
    final results = await Future.wait<String>([
      translateArToEn(title),
      translateArToEn(content),
    ]);

    return {
      'title_en': results[0],
      'content_en': results[1],
    };
  }
}