class News {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String categoryId;
  final String locationId;
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
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      imageUrl: json['image_url'],
      categoryId: json['category_id'],
      locationId: json['location_id'],
      createdAt: DateTime.parse(json['created_at']),
      isHidden: json['is_hidden'],
      isFeatured: json['is_featured'],
      sentNotification: json['sent_notification'],
      viewCount: json['view_count'] ?? 0,
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
