import 'package:flutter/material.dart';

import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../data/models/category_model.dart';
import '../../data/models/news_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../../news/presentation/screens/saved_news_screen.dart';
import '../widgets/breaking_ticker.dart';
import '../widgets/category_chips.dart';
import '../widgets/news_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _repository = HomeRepository();

  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<NewsModel>> _latestNewsFuture;
  late Future<List<String>> _breakingFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _categoriesFuture = _repository.getCategories();
    _latestNewsFuture = _repository.getLatestNews(limit: 10);
    _breakingFuture = _repository.getActiveBreakingNewsTitles();
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await Future.wait<void>([
      _categoriesFuture.then((_) => null),
      _latestNewsFuture.then((_) => null),
      _breakingFuture.then((_) => null),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإخبارية السورية'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedNewsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bookmark_outline_rounded),
            tooltip: 'الأخبار المحفوظة',
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            FutureBuilder<List<String>>(
              future: _breakingFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return BreakingTicker(titles: snapshot.data!);
              },
            ),
            const SectionTitle(title: 'التصنيفات'),
            FutureBuilder<List<CategoryModel>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 52,
                    child: CategoryChipsShimmer(),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('تعذر تحميل التصنيفات: ${snapshot.error}'),
                  );
                }
                return CategoryChips(categories: snapshot.data ?? const []);
              },
            ),
            const SectionTitle(title: 'أحدث الأخبار'),
            FutureBuilder<List<NewsModel>>(
              future: _latestNewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(5, (_) => const NewsCardShimmer()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('تعذر تحميل الأخبار: ${snapshot.error}'),
                  );
                }

                final news = snapshot.data ?? const [];
                if (news.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('لا توجد أخبار حالياً'),
                  );
                }

                return Column(
                  children: news.map((item) => NewsCard(news: item)).toList(),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
