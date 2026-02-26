class VideoCategoryModel {
  final int id;
  final String name;
  final String slug;
  final int orderIndex;

  const VideoCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.orderIndex,
  });

  factory VideoCategoryModel.fromJson(Map<String, dynamic> json) {
    return VideoCategoryModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}