class LiveStreamModel {
  final int id;
  final String youtubeUrl;
  final bool isActive;
  final String? broadcastTitle;
  final String? fallbackMessage;

  const LiveStreamModel({
    required this.id,
    required this.youtubeUrl,
    required this.isActive,
    required this.broadcastTitle,
    required this.fallbackMessage,
  });

  factory LiveStreamModel.fromJson(
    Map<String, dynamic> json, {
    String languageCode = 'ar',
  }) {
    final normalizedLanguage = languageCode.toLowerCase();
    final fallbackLanguage = normalizedLanguage == 'en' ? 'ar' : 'en';

    String? pickText(String baseKey) {
      final preferred =
          json['${baseKey}_$normalizedLanguage']?.toString().trim();
      if (preferred != null && preferred.isNotEmpty) return preferred;

      final base = json[baseKey]?.toString().trim();
      if (base != null && base.isNotEmpty) return base;

      final fallback = json['${baseKey}_$fallbackLanguage']?.toString().trim();
      if (fallback != null && fallback.isNotEmpty) return fallback;
      return null;
    }

    return LiveStreamModel(
      id: json['id'] as int,
      youtubeUrl: (json['youtube_url'] as String?) ?? '',
      isActive: json['is_active'] as bool? ?? false,
      broadcastTitle: pickText('broadcast_title') ?? pickText('title'),
      fallbackMessage: pickText('fallback_message'),
    );
  }
}
