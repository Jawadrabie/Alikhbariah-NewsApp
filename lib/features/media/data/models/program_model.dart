class ProgramModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int orderIndex;

  const ProgramModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.orderIndex,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}
