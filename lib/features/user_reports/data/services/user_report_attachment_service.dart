import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserReportAttachmentService {
  static const int _maxFileSizeBytes = 8 * 1024 * 1024;

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> pickAndUploadAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('empty_attachment');
    }

    if (bytes.length > _maxFileSizeBytes) {
      throw Exception('attachment_too_large');
    }

    final extension = (file.extension ?? 'jpg').toLowerCase();
    final contentType = _contentTypeFor(extension);
    final objectPath = 'user-reports/${DateTime.now().millisecondsSinceEpoch}_${_sanitizeFileName(file.name)}';

    await _supabase.storage
        .from('news-images')
        .uploadBinary(
          objectPath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

    return _supabase.storage.from('news-images').getPublicUrl(objectPath);
  }

  String _contentTypeFor(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }

  String _sanitizeFileName(String raw) {
    final normalized = raw.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    if (normalized.isEmpty) return 'attachment.jpg';
    return normalized;
  }
}
