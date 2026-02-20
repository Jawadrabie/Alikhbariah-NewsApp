class VideoItemModel {
  final int id;
  final String title;
  final String youtubeUrl;
  final String? thumbnailUrl;
  final DateTime? publishedAt;
  final DateTime createdAt;

  const VideoItemModel({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.createdAt,
  });

  factory VideoItemModel.fromJson(Map<String, dynamic> json) {
    return VideoItemModel(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      youtubeUrl: (json['youtube_url'] as String?) ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.tryParse(json['published_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
