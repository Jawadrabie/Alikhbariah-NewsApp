import 'package:supabase_flutter/supabase_flutter.dart';

class UserReportSubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> submitReport({
    String? name,
    String? phone,
    required String message,
    String? attachmentUrl,
  }) async {
    await _supabase.from('user_reports').insert({
      'name': _normalizeOptional(name),
      'phone': _normalizeOptional(phone),
      'message': message.trim(),
      'attachment_url': _normalizeOptional(attachmentUrl),
    });
  }

  String? _normalizeOptional(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }
}
