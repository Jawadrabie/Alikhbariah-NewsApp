import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../home/data/models/news_model.dart';

class BookmarkService {
  static const String _bookmarksKey = 'saved_news_items';

  Future<List<NewsModel>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_bookmarksKey) ?? const [];

    return rawList
        .map((item) => _decodeNews(item))
        .whereType<NewsModel>()
        .toList();
  }

  Future<bool> isBookmarked(int newsId) async {
    final items = await getBookmarks();
    return items.any((item) => item.id == newsId);
  }

  Future<bool> toggleBookmark(NewsModel news) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getBookmarks();
    final exists = items.any((item) => item.id == news.id);

    List<NewsModel> nextItems;
    if (exists) {
      nextItems = items.where((item) => item.id != news.id).toList();
    } else {
      nextItems = [news, ...items.where((item) => item.id != news.id)];
    }

    final encoded = nextItems.map(_encodeNews).toList();
    await prefs.setStringList(_bookmarksKey, encoded);
    return !exists;
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
    };

    return jsonEncode(payload);
  }

  NewsModel? _decodeNews(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return NewsModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}