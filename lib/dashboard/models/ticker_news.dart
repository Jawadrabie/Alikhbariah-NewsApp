class TickerNews {
  final String id;
  final String text;
  final bool isActive;
  final int priority;
  final String? linkedNewsId;
  final DateTime createdAt;

  TickerNews({
    required this.id,
    required this.text,
    required this.isActive,
    required this.priority,
    required this.linkedNewsId,
    required this.createdAt,
  });

  factory TickerNews.fromJson(Map<String, dynamic> json) {
    return TickerNews(
      id: json['id'].toString(),
      text: (json['text'] ?? '') as String,
      isActive: (json['is_active'] ?? false) as bool,
      priority: (json['priority'] ?? 0) as int,
      linkedNewsId: json['linked_news_id']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_active': isActive,
      'priority': priority,
      'linked_news_id': linkedNewsId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
