import 'package:flutter/material.dart';

import '../../../home/data/models/news_model.dart';
import '../../../home/presentation/widgets/news_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../data/services/bookmark_service.dart';

class SavedNewsScreen extends StatefulWidget {
  const SavedNewsScreen({super.key});

  @override
  State<SavedNewsScreen> createState() => _SavedNewsScreenState();
}

class _SavedNewsScreenState extends State<SavedNewsScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  late Future<List<NewsModel>> _savedNewsFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedNews();
  }

  void _loadSavedNews() {
    _savedNewsFuture = _bookmarkService.getBookmarks();
  }

  Future<void> _refresh() async {
    setState(_loadSavedNews);
    await _savedNewsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأخبار المحفوظة'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<NewsModel>>(
          future: _savedNewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                padding: const EdgeInsets.only(top: 12),
                children: List.generate(5, (_) => const NewsCardShimmer()),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('تعذر تحميل الأخبار المحفوظة: ${snapshot.error}'),
                  ),
                ],
              );
            }

            final savedNews = snapshot.data ?? const [];
            if (savedNews.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.bookmark_border_rounded, size: 42, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 10),
                  Center(child: Text('لا توجد أخبار محفوظة حتى الآن')),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 12),
              itemCount: savedNews.length,
              itemBuilder: (context, index) {
                final item = savedNews[index];
                return Dismissible(
                  key: Key(item.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.red,
                    padding: const EdgeInsets.only(left: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    // Remove from local storage
                    await _bookmarkService.toggleBookmark(item);
                    
                    // Refresh the list
                    // In a more complex app, we would update a provider or state manager
                    // Here we just trigger a reload of the future to sync UI
                    _refresh();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم حذف الخبر من المحفوظات'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: NewsCard(news: item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}