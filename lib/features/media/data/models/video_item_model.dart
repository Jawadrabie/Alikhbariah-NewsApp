import '../../../../core/utils/image_url_utils.dart';

class VideoItemModel {
  final int id;
  final String title;
  final String youtubeUrl;
  final int? categoryId;
  final int? programId;
  final String? thumbnailUrl;
  final DateTime? publishedAt;
  final DateTime createdAt;

  const VideoItemModel({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.categoryId,
    required this.programId,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.createdAt,
  });

  factory VideoItemModel.fromJson(
    Map<String, dynamic> json, {
    String languageCode = 'ar',
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    final fallbackLanguage = normalizedLanguage == 'en' ? 'ar' : 'en';

    String readText(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return VideoItemModel(
      id: json['id'] as int,
      title:
          readText(json['title_$normalizedLanguage']).isNotEmpty
              ? readText(json['title_$normalizedLanguage'])
              : (readText(json['title']).isNotEmpty
                  ? readText(json['title'])
                  : readText(json['title_$fallbackLanguage'])),
      youtubeUrl: (json['youtube_url'] as String?) ?? '',
      categoryId: json['category_id'] as int?,
      programId: json['program_id'] as int?,
      thumbnailUrl: normalizeRemoteImageUrl(json['thumbnail_url'] as String?),
      publishedAt:
          json['published_at'] == null
              ? null
              : DateTime.tryParse(json['published_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
