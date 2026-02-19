class Program {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int orderIndex;
  final bool isActive;
  final DateTime createdAt;

  Program({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.orderIndex,
    required this.isActive,
    required this.createdAt,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'].toString(),
      name: (json['name'] ?? '') as String,
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      orderIndex: (json['order_index'] ?? 0) as int,
      isActive: (json['is_active'] ?? true) as bool,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'order_index': orderIndex,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
