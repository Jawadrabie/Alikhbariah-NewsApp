class UserReport {
  final String id;
  final String? name;
  final String? phone;
  final String message;
  final String? attachmentUrl;
  final DateTime createdAt;
  final bool isReviewed;

  UserReport({
    required this.id,
    required this.name,
    required this.phone,
    required this.message,
    required this.attachmentUrl,
    required this.createdAt,
    required this.isReviewed,
  });

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'].toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      message: (json['message'] ?? '') as String,
      attachmentUrl: json['attachment_url']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      isReviewed: (json['is_reviewed'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'message': message,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
      'is_reviewed': isReviewed,
    };
  }
}
