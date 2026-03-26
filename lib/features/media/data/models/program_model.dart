import '../../../../core/utils/image_url_utils.dart';

class ProgramModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int orderIndex;
  final bool isActive;

  const ProgramModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.orderIndex,
    this.isActive = true,
  });

  factory ProgramModel.fromJson(
    Map<String, dynamic> json, {
    String languageCode = 'ar',
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    final fallbackLanguage = normalizedLanguage == 'en' ? 'ar' : 'en';

    String readText(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    String pickText(String baseKey) {
      final preferred = readText(json['${baseKey}_$normalizedLanguage']);
      if (preferred.isNotEmpty) return preferred;
      final base = readText(json[baseKey]);
      if (base.isNotEmpty) return base;
      return readText(json['${baseKey}_$fallbackLanguage']);
    }

    return ProgramModel(
      id: json['id'] as int,
      name: pickText('name'),
      description:
          pickText('description').isEmpty ? null : pickText('description'),
      imageUrl: normalizeRemoteImageUrl(json['image_url'] as String?),
      orderIndex: json['order_index'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
