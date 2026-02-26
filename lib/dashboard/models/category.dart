class Category {
  final String id;
  final String name;
  final String? slug;
  final int orderIndex;
  final String type;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.orderIndex,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: (json['name'] ?? '') as String,
      slug: json['slug']?.toString(),
      orderIndex: (json['order_index'] ?? 0) as int,
      type: (json['type'] ?? 'news').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'order_index': orderIndex,
      'type': type,
    };
  }
}
