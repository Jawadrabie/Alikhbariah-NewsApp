class VideoItem {
  final String id;
  final String title;
  final String titleEn;
  final String youtubeUrl;
  final String? programId;
  final String? categoryId;
  final String? thumbnailUrl;
  final int orderIndex;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final bool isHidden;

  VideoItem({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.youtubeUrl,
    required this.programId,
    required this.categoryId,
    required this.thumbnailUrl,
    required this.orderIndex,
    required this.publishedAt,
    required this.createdAt,
    required this.isHidden,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'].toString(),
      title: (json['title'] ?? '') as String,
      titleEn: (json['title_en'] ?? '') as String,
      youtubeUrl: (json['youtube_url'] ?? '') as String,
      programId: json['program_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      orderIndex: (json['order_index'] ?? 0) as int,
      publishedAt: DateTime.tryParse(json['published_at']?.toString() ?? ''),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      isHidden: (json['is_hidden'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_en': titleEn,
      'youtube_url': youtubeUrl,
      'program_id': programId,
      'category_id': categoryId,
      'thumbnail_url': thumbnailUrl,
      'order_index': orderIndex,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_hidden': isHidden,
    };
  }
}
