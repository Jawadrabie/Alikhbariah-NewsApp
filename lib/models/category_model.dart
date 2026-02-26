class CategoryModel {
  final int id;
  final String name;
  final String? nameEn;
  final String slug;
  final int orderIndex;
  final int? parentId;
  final String type;

  CategoryModel({
    required this.id,
    required this.name,
    this.nameEn,
    required this.slug,
    this.orderIndex = 0,
    this.parentId,
    this.type = 'news',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      slug: json['slug'] as String,
      orderIndex: json['order_index'] as int,
      parentId: json['parent_id'] as int?,
      type: (json['type'] as String?) ?? 'news',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'slug': slug,
      'order_index': orderIndex,
      'parent_id': parentId,
      'type': type,
    };
  }
}
