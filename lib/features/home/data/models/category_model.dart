class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final int orderIndex;
  final int? parentId;
  final String type;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.orderIndex,
    required this.parentId,
    required this.type,
  });

  factory CategoryModel.fromJson(
    Map<String, dynamic> json, {
    String languageCode = 'ar',
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    return CategoryModel(
      id: json['id'] as int,
      name: _localizedName(json, normalizedLanguage),
      slug: json['slug'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
      parentId: json['parent_id'] as int?,
      type: (json['type'] as String?) ?? 'news',
    );
  }

  static String _localizedName(Map<String, dynamic> json, String languageCode) {
    final preferred = _readText(json['name_$languageCode']);
    if (preferred != null && preferred.isNotEmpty) {
      return preferred;
    }

    final baseName = _readText(json['name']);
    if (baseName != null && baseName.isNotEmpty) {
      return baseName;
    }

    final fallbackLanguage = languageCode == 'en' ? 'ar' : 'en';
    final fallback = _readText(json['name_$fallbackLanguage']);
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }

    return '';
  }

  static String? _readText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}
