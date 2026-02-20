import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../data/models/category_model.dart';
import '../../data/models/featured_slider_settings_model.dart';
import '../../data/models/news_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../../news/presentation/screens/saved_news_screen.dart';
import '../widgets/breaking_ticker.dart';
import '../widgets/category_chips.dart';
import '../widgets/featured_slider.dart';
import '../widgets/home_drawer.dart';
import '../widgets/news_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeRepository _repository = HomeRepository();
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;

  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<NewsModel>> _featuredFuture;
  late Future<List<String>> _breakingFuture;
  late Future<FeaturedSliderSettingsModel> _sliderSettingsFuture;

  List<NewsModel> _latestNews = const [];
  bool _isInitialNewsLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreNews = true;
  int _offset = 0;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    _categoriesFuture = _repository.getCategories();
    _featuredFuture = _repository.getFeaturedNews(limit: 5);
    _breakingFuture = _repository.getActiveBreakingNewsTitles();
    _sliderSettingsFuture = _repository.getFeaturedSliderSettings();
    _loadInitialNews();
  }

  Future<void> _loadInitialNews() async {
    setState(() {
      _isInitialNewsLoading = true;
      _isLoadingMore = false;
      _offset = 0;
      _hasMoreNews = true;
      _latestNews = const [];
    });

    await _loadMoreNews();
    if (!mounted) return;
    setState(() => _isInitialNewsLoading = false);
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore || !_hasMoreNews) return;

    setState(() => _isLoadingMore = true);

    try {
      final items = await _repository.getLatestNews(
        limit: _pageSize,
        offset: _offset,
        categoryId: _selectedCategoryId,
      );

      if (!mounted) return;
      setState(() {
        _latestNews = [..._latestNews, ...items];
        _offset += items.length;
        _hasMoreNews = items.length == _pageSize;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMoreNews();
    }
  }

  Future<void> _onCategorySelected(int? categoryId) async {
    if (categoryId == null) {
      setState(() => _selectedCategoryId = null);
      await _loadInitialNews();
      return;
    }

    final nextCategory = _selectedCategoryId == categoryId ? null : categoryId;
    setState(() => _selectedCategoryId = nextCategory);
    await _loadInitialNews();
  }

  Future<void> _refresh() async {
    setState(() {
      _categoriesFuture = _repository.getCategories();
      _featuredFuture = _repository.getFeaturedNews(limit: 5);
      _breakingFuture = _repository.getActiveBreakingNewsTitles();
      _sliderSettingsFuture = _repository.getFeaturedSliderSettings();
    });

    await _loadInitialNews();

    await Future.wait<void>([
      _categoriesFuture.then((_) => null),
      _featuredFuture.then((_) => null),
      _breakingFuture.then((_) => null),
      _sliderSettingsFuture.then((_) => null),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      drawer: const HomeDrawer(),
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.quickSearchInProgress)),
              );
            },
            icon: const Icon(Icons.search_rounded),
            tooltip: l10n.search,
          ),
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
            tooltip: l10n.savedNews,
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          children: [
            FutureBuilder<List<String>>(
              future: _breakingFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                return BreakingTicker(titles: snapshot.data!);
              },
            ),
            SectionTitle(title: l10n.categories),
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
                    child: Text(l10n.failedLoadCategories(snapshot.error.toString())),
                  );
                }

                return CategoryChips(
                  categories: snapshot.data ?? const [],
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: _onCategorySelected,
                );
              },
            ),
            SectionTitle(title: l10n.featuredNews),
            FutureBuilder<List<NewsModel>>(
              future: _featuredFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ShimmerLoading(
                      width: double.infinity,
                      height: 220,
                      borderRadius: 14,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(l10n.failedLoadFeaturedNews(snapshot.error.toString())),
                  );
                }

                return FutureBuilder<FeaturedSliderSettingsModel>(
                  future: _sliderSettingsFuture,
                  builder: (context, settingsSnapshot) {
                    final settings = settingsSnapshot.data ??
                        const FeaturedSliderSettingsModel(
                          autoplay: true,
                          intervalSeconds: 3,
                        );

                    return FeaturedSlider(
                      items: snapshot.data ?? const [],
                      autoplay: settings.autoplay,
                      interval: Duration(seconds: settings.intervalSeconds),
                    );
                  },
                );
              },
            ),
            SectionTitle(title: l10n.latestNews),
            if (_isInitialNewsLoading)
              Column(children: List.generate(5, (_) => const NewsCardShimmer()))
            else if (_latestNews.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(l10n.noNewsNow),
              )
            else
              Column(
                children: _latestNews.map((item) => NewsCard(news: item)).toList(),
              ),
            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (!_isInitialNewsLoading && !_hasMoreNews && _latestNews.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    l10n.allNewsShown,
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
