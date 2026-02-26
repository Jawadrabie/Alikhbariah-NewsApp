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

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      id: json['id'] as int,
      youtubeUrl: (json['youtube_url'] as String?) ?? '',
      isActive: json['is_active'] as bool? ?? false,
      broadcastTitle: (json['broadcast_title'] ?? json['title']) as String?,
      fallbackMessage: json['fallback_message'] as String?,
    );
  }
}
