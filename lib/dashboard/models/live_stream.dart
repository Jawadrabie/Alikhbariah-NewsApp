class LiveStream {
  final String id;
  final String youtubeUrl;
  final bool isActive;
  final String broadcastTitle;
  final String broadcastTitleEn;
  final String fallbackMessage;
  final String fallbackMessageEn;

  LiveStream({
    required this.id,
    required this.youtubeUrl,
    required this.isActive,
    required this.broadcastTitle,
    required this.broadcastTitleEn,
    required this.fallbackMessage,
    required this.fallbackMessageEn,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      id: json['id'].toString(),
      youtubeUrl: (json['youtube_url'] ?? '') as String,
      isActive: (json['is_active'] ?? false) as bool,
      broadcastTitle: (json['broadcast_title'] ?? json['title'] ?? '') as String,
      broadcastTitleEn: (json['broadcast_title_en'] ?? '') as String,
      fallbackMessage: (json['fallback_message'] ?? '') as String,
      fallbackMessageEn: (json['fallback_message_en'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'youtube_url': youtubeUrl,
      'is_active': isActive,
      'broadcast_title': broadcastTitle,
      'broadcast_title_en': broadcastTitleEn,
      'fallback_message': fallbackMessage,
      'fallback_message_en': fallbackMessageEn,
    };
  }
}
