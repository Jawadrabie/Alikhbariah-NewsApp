class News {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String categoryId;
  final String? locationId;
  final DateTime createdAt;
  final bool isHidden;
  final bool isFeatured;
  final bool sentNotification;
  final int viewCount;

  News({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.categoryId,
    required this.locationId,
    required this.createdAt,
    required this.isHidden,
    required this.isFeatured,
    required this.sentNotification,
    this.viewCount = 0,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '') as String,
      summary: (json['summary'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      imageUrl: (json['image_url'] ?? '') as String,
      categoryId: (json['category_id'] ?? '').toString(),
      locationId: json['location_id']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      isHidden: json['is_hidden'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      sentNotification: json['sent_notification'] as bool? ?? true,
      viewCount: (json['view_count'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'image_url': imageUrl,
      'category_id': categoryId,
      'location_id': locationId,
      'created_at': createdAt.toIso8601String(),
      'is_hidden': isHidden,
      'is_featured': isFeatured,
      'sent_notification': sentNotification,
      'view_count': viewCount,
    };
  }
}
