class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final int orderIndex;
  final int? parentId;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.orderIndex,
    required this.parentId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
      parentId: json['parent_id'] as int?,
    );
  }
}
