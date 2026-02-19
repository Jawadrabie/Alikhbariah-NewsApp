class NewsModel {
  final int id;
  final String title;
  final String? summary;
  final String content;
  final String? imageUrl;
  final int? categoryId;
  final DateTime createdAt;
  final bool isFeatured;

  const NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.categoryId,
    required this.createdAt,
    required this.isFeatured,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as int,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }
}
