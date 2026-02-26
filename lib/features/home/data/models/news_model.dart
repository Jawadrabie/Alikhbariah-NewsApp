class NewsModel {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final int? categoryId;
  final DateTime createdAt;
  final bool isFeatured;
  final int viewCount;

  const NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.categoryId,
    required this.createdAt,
    this.isFeatured = false,
    this.viewCount = 0,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json, {String languageCode = 'ar'}) {
    final normalizedLanguage = languageCode.toLowerCase();
    
    String localized(String key) {
        // 1. Try key_lang (e.g. title_en)
        final localizedKey = '${key}_$normalizedLanguage';
        if (json[localizedKey] != null && json[localizedKey].toString().isNotEmpty) {
            return json[localizedKey].toString();
        }
        // 2. Try default key (e.g. title) - assumed to be Arabic or primary
        if (json[key] != null && json[key].toString().isNotEmpty) {
            return json[key].toString();
        }
        // 3. Try other lang (e.g. title_ar if we asked for en but it's missing)
        // Just fallback to empty if nothing works
        return '';
    }

    return NewsModel(
      id: json['id'] as int,
      title: localized('title'),
      content: localized('content'),
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isFeatured: json['is_featured'] as bool? ?? false,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
    );
  }
}

