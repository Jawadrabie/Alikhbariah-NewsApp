import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Picks an image from gallery and uploads it to Supabase Storage.
  /// Returns the public URL of the uploaded image.
  Future<String?> pickAndUploadImage({
    String bucketName = 'news-images',
    String? folder,
  }) async {
    // 1. Pick Image (works on Web/Desktop/Mobile)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.first;
    final bytes = picked.bytes;
    if (bytes == null) {
      throw Exception('upload_failed');
    }

    // 2. Size check (enforce 5 MB limit)
    const int maxBytes = 5 * 1024 * 1024;
    final fileSize = bytes.length;
    if (fileSize > maxBytes) {
      debugPrint('Selected file too large: $fileSize bytes (limit: $maxBytes)');
      throw Exception('file_too_large');
    }

    // 3. Prepare file path
    final fileExt = (picked.extension ?? 'jpg').toLowerCase();
    final fileName = '${_uuid.v4()}.$fileExt';
    final filePath = folder != null ? '$folder/$fileName' : fileName;

    // 4. Determine Mime Type
    String mimeType = 'application/octet-stream';
    if (fileExt.toLowerCase() == 'jpg' || fileExt.toLowerCase() == 'jpeg') {
      mimeType = 'image/jpeg';
    } else if (fileExt.toLowerCase() == 'png') {
      mimeType = 'image/png';
    } else if (fileExt.toLowerCase() == 'gif') {
      mimeType = 'image/gif';
    } else if (fileExt.toLowerCase() == 'webp') {
      mimeType = 'image/webp';
    }

    try {
      // 5. Upload to Supabase
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType),
          );

      // 6. Get Public URL
      return _supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      debugPrint('Error uploading image: $e');
      throw Exception('upload_failed');
    }
  }
}
