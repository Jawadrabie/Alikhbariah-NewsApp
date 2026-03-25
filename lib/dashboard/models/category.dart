class Category {
  final String id;
  final String name;
  final String nameEn;
  final String? slug;
  final String? coverImageUrl;
  final int orderIndex;
  final String type;
  final int videoCount;

  Category({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.slug,
    required this.coverImageUrl,
    required this.orderIndex,
    required this.type,
    this.videoCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: (json['name'] ?? '') as String,
      nameEn: (json['name_en'] ?? '') as String,
      slug: json['slug']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      orderIndex: (json['order_index'] ?? 0) as int,
      type: (json['type'] ?? 'news').toString(),
      videoCount:
          (json['video_count'] != null) ? (json['video_count'] as int) : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'slug': slug,
      'cover_image_url': coverImageUrl,
      'order_index': orderIndex,
      'type': type,
    };
  }
}
