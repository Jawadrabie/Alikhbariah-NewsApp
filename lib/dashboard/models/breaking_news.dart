class BreakingNews {
  final String id;
  final String title;
  final String titleEn;
  final String content;
  final String contentEn;
  final DateTime createdAt;
  final DateTime startTime;
  final DateTime endTime;
  final bool sendNotification;

  BreakingNews({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.content,
    required this.contentEn,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.sendNotification,
  });

  factory BreakingNews.fromJson(Map<String, dynamic> json) {
    return BreakingNews(
      id: (json['id'] ?? '').toString(),
      title: json['title'],
      titleEn: (json['title_en'] ?? '') as String,
      content: json['content'],
      contentEn: (json['content_en'] ?? '') as String,
      createdAt: DateTime.parse(json['created_at']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      sendNotification: json['send_notification'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_en': titleEn,
      'content': content,
      'content_en': contentEn,
      'created_at': createdAt.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'send_notification': sendNotification,
    };
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}
