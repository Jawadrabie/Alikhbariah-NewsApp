class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final int orderIndex;
  final int? parentId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.orderIndex = 0,
    this.parentId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      orderIndex: json['order_index'] as int,
      parentId: json['parent_id'] as int?,
    );
  }
}
