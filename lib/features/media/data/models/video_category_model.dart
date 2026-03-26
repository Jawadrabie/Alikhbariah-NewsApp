import '../../../../core/utils/image_url_utils.dart';

class VideoCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? coverImageUrl;
  final int orderIndex;

  const VideoCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.coverImageUrl,
    required this.orderIndex,
  });

  factory VideoCategoryModel.fromJson(
    Map<String, dynamic> json, {
    String languageCode = 'ar',
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    final fallbackLanguage = normalizedLanguage == 'en' ? 'ar' : 'en';

    String readText(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return VideoCategoryModel(
      id: json['id'] as int,
      name:
          readText(json['name_$normalizedLanguage']).isNotEmpty
              ? readText(json['name_$normalizedLanguage'])
              : (readText(json['name']).isNotEmpty
                  ? readText(json['name'])
                  : readText(json['name_$fallbackLanguage'])),
      slug: (json['slug'] as String?) ?? '',
      coverImageUrl: normalizeRemoteImageUrl(json['cover_image_url']?.toString()),
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}
