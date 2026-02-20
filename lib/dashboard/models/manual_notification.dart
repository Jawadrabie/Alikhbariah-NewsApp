class ManualNotification {
  final String id;
  final String title;
  final String body;
  final DateTime sentAt;
  final String? createdBy;
  final int viewCount;

  ManualNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
    required this.createdBy,
    required this.viewCount,
  });

  factory ManualNotification.fromJson(Map<String, dynamic> json) {
    return ManualNotification(
      id: json['id'].toString(),
      title: (json['title'] ?? '') as String,
      body: (json['body'] ?? '') as String,
      sentAt: DateTime.tryParse(json['sent_at']?.toString() ?? '') ?? DateTime.now(),
      createdBy: json['created_by']?.toString(),
      viewCount: (json['view_count'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'sent_at': sentAt.toIso8601String(),
      'created_by': createdBy,
      'view_count': viewCount,
    };
  }
}
