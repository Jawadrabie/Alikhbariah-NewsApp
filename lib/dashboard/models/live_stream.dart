class LiveStream {
  final String id;
  final String youtubeUrl;
  final bool isActive;
  final String broadcastTitle;
  final String fallbackMessage;

  LiveStream({
    required this.id,
    required this.youtubeUrl,
    required this.isActive,
    required this.broadcastTitle,
    required this.fallbackMessage,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      id: json['id'].toString(),
      youtubeUrl: (json['youtube_url'] ?? '') as String,
      isActive: (json['is_active'] ?? false) as bool,
      broadcastTitle: (json['broadcast_title'] ?? '') as String,
      fallbackMessage: (json['fallback_message'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'youtube_url': youtubeUrl,
      'is_active': isActive,
      'broadcast_title': broadcastTitle,
      'fallback_message': fallbackMessage,
    };
  }
}
