import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../home/data/models/news_model.dart';

class BookmarkService {
  static const String _bookmarksBox = 'saved_news_items';

  Future<Box<String>> _openBox() {
    return Hive.openBox<String>(_bookmarksBox);
  }

  Future<List<NewsModel>> getBookmarks() async {
    final box = await _openBox();
    final items = box.values
        .map((item) => _decodeNews(item))
        .whereType<NewsModel>()
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return items;
  }

  Future<List<NewsModel>> getBookmarksBySavedTime() async {
    final box = await _openBox();

    final decoded = box.values
        .map((raw) {
          final data = _decodeMap(raw);
          if (data == null) return null;

          final news = NewsModel.fromJson(data);
          final savedAtRaw = data['saved_at'] as String?;
          final savedAt = savedAtRaw != null
              ? DateTime.tryParse(savedAtRaw) ?? news.createdAt
              : news.createdAt;

          return (news: news, savedAt: savedAt);
        })
        .whereType<({NewsModel news, DateTime savedAt})>()
        .toList();

    decoded.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return decoded.map((item) => item.news).toList();
  }

  Future<bool> isBookmarked(int newsId) async {
    final box = await _openBox();
    return box.containsKey(newsId.toString());
  }

  Future<bool> toggleBookmark(NewsModel news) async {
    final box = await _openBox();
    final key = news.id.toString();
    final exists = box.containsKey(key);

    if (exists) {
      await box.delete(key);
    } else {
      await box.put(key, _encodeNews(news));
    }

    return !exists;
  }

  Future<void> removeBookmark(int newsId) async {
    final box = await _openBox();
    await box.delete(newsId.toString());
  }

  String _encodeNews(NewsModel news) {
    final payload = <String, dynamic>{
      'id': news.id,
      'title': news.title,
      'summary': news.summary,
      'content': news.content,
      'image_url': news.imageUrl,
      'category_id': news.categoryId,
      'created_at': news.createdAt.toIso8601String(),
      'is_featured': news.isFeatured,
      'saved_at': DateTime.now().toIso8601String(),
    };

    return jsonEncode(payload);
  }

  Map<String, dynamic>? _decodeMap(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map;
    } catch (_) {
      return null;
    }
  }

  NewsModel? _decodeNews(String raw) {
    final map = _decodeMap(raw);
    if (map == null) return null;

    try {
      return NewsModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}