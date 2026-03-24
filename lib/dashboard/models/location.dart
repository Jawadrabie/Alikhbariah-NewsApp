class Location {
  final String id;
  final String name;
  final String? nameEn;
  final String? slug;

  Location({
    required this.id,
    required this.name,
    this.nameEn,
    this.slug,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'].toString(),
      name: (json['name'] ?? '') as String,
      nameEn: json['name_en']?.toString(),
      slug: json['slug']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'slug': slug,
    };
  }
}
