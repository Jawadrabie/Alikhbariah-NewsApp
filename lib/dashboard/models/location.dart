class Location {
  final String id;
  final String name;
  final String? slug;

  Location({required this.id, required this.name, required this.slug});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'].toString(),
      name: (json['name'] ?? '') as String,
      slug: json['slug']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}
