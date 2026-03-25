import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserReportAttachmentService {
  static const int _maxFileSizeBytes = 8 * 1024 * 1024;
  static const String _bucketName = 'news-images';
  static const String _folderName = 'user-reports';
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> pickAndUploadAttachment() async {
    final file = await _pickAttachment();
    if (file == null) return null;

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('empty_attachment');
    }

    if (bytes.length > _maxFileSizeBytes) {
      throw Exception('attachment_too_large');
    }

    final objectPath = _buildObjectPath(file);
    final contentType = _contentTypeFor(file.extension);

    await _supabase.storage
        .from(_bucketName)
        .uploadBinary(
          objectPath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

    return _supabase.storage.from(_bucketName).getPublicUrl(objectPath);
  }

  Future<PlatformFile?> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    return result.files.single;
  }

  String _buildObjectPath(PlatformFile file) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedName = _sanitizeFileName(file.name);
    return '$_folderName/${timestamp}_$sanitizedName';
  }

  String _contentTypeFor(String? extension) {
    switch ((extension ?? 'jpg').toLowerCase()) {
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
