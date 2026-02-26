class NewsModel {
  final int id;
  final String title;
  final String? titleEn;
  final String content;
  final String? contentEn;
  final String? imageUrl;
  final int? categoryId;
  final DateTime createdAt;
  final bool isFeatured;
  final int viewCount;

  NewsModel({
    required this.id,
    required this.title,
    this.titleEn,
    required this.content,
    this.contentEn,
    this.imageUrl,
    this.categoryId,
    required this.createdAt,
    this.isFeatured = false,
    this.viewCount = 0,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as int,
      title: json['title'] as String,
      titleEn: json['title_en'] as String?,
      content: json['content'] as String,
      contentEn: json['content_en'] as String?,
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isFeatured: json['is_featured'] as bool? ?? false,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_en': titleEn,
      'content': content,
      'content_en': contentEn,
      'image_url': imageUrl,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'is_featured': isFeatured,
      'view_count': viewCount,
    };
  }
}
