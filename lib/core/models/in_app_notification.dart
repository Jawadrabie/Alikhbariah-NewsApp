class InAppNotification {
  const InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.source,
    required this.data,
  });

  final String id;
  final String? title;
  final String? body;
  final DateTime receivedAt;
  final String source;
  final Map<String, dynamic> data;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'received_at': receivedAt.toIso8601String(),
      'source': source,
      'data': data,
    };
  }

  factory InAppNotification.fromMap(Map<String, dynamic> map) {
    final rawData = map['data'];
    return InAppNotification(
      id: (map['id'] as String?) ?? DateTime.now().toIso8601String(),
      title: map['title'] as String?,
      body: map['body'] as String?,
      receivedAt:
          DateTime.tryParse((map['received_at'] as String?) ?? '') ??
          DateTime.now(),
      source: (map['source'] as String?) ?? 'push',
      data:
          rawData is Map
              ? Map<String, dynamic>.from(rawData)
              : const <String, dynamic>{},
    );
  }
}