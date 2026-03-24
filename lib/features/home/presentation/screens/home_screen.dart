import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../data/models/category_model.dart';
import '../../data/models/featured_slider_settings_model.dart';
import '../../data/models/news_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../../media/data/models/video_category_model.dart';
import '../../../media/data/repositories/media_repository.dart';
import '../../../media/presentation/screens/videos_screen.dart';
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
  final MediaRepository _mediaRepository = MediaRepository();
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 10;

  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<NewsModel>> _featuredFuture;
  late Future<List<VideoCategoryModel>> _videoCategoriesFuture;
  late Future<FeaturedSliderSettingsModel> _sliderSettingsFuture;

  List<NewsModel> _latestNews = const [];
  List<NewsModel> _categoryNews = const [];
  List<String> _breakingTitles = const [];
  bool _isInitialNewsLoading = true;
  bool _isLoadingMore = false;
  bool _isCategoryNewsLoading = false;
  bool _hasMoreNews = true;
  int _offset = 0;
  int? _selectedCategoryId;
  String _currentLanguageCode = 'ar';

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Localizations.localeOf(context).languageCode.toLowerCase();
    if (_currentLanguageCode == languageCode) {
      return;
    }

    _currentLanguageCode = languageCode;
    _loadData();
    if (_selectedCategoryId != null) {
      _onCategorySelected(_selectedCategoryId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    // 1. Categories
    final cachedCats = _repository.getCachedCategories(languageCode: _currentLanguageCode);
    if (cachedCats != null) {
      _categoriesFuture = Future.value(cachedCats);
      // Fetch fresh in background
      _repository.getCategories(
          languageCode: _currentLanguageCode,
          forceRefresh: true,
      ).then((fresh) {
        if (mounted) setState(() => _categoriesFuture = Future.value(fresh));
      });
    } else {
      _categoriesFuture = _repository.getCategories(languageCode: _currentLanguageCode);
    }

    // 2. Featured News
    final cachedFeatured = _repository.getCachedFeaturedNews(languageCode: _currentLanguageCode, limit: 5);
    if (cachedFeatured != null) {
      _featuredFuture = Future.value(cachedFeatured);
      _repository.getFeaturedNews(
        languageCode: _currentLanguageCode,
        limit: 5,
        forceRefresh: true,
      ).then((fresh) {
        if (mounted) setState(() => _featuredFuture = Future.value(fresh));
      });
    } else {
      _featuredFuture = _repository.getFeaturedNews(
        languageCode: _currentLanguageCode,
        limit: 5,
      );
    }

    // 3. Video categories
    final cachedVideoCategories = _mediaRepository.getCachedVideoCategories();
    if (cachedVideoCategories != null) {
      _videoCategoriesFuture = Future.value(cachedVideoCategories);
      _mediaRepository.getVideoCategories(forceRefresh: true).then((fresh) {
         if (mounted) {
           setState(() => _videoCategoriesFuture = Future.value(fresh));
         }
      });
    } else {
      _videoCategoriesFuture = _mediaRepository.getVideoCategories();
    }

    // 4. Slider Settings
    final cachedSettings = _repository.getCachedFeaturedSliderSettings();
    if (cachedSettings != null) {
      _sliderSettingsFuture = Future.value(cachedSettings);
      _repository.getFeaturedSliderSettings(forceRefresh: true).then((fresh) {
        if (mounted) setState(() => _sliderSettingsFuture = Future.value(fresh));
      });
    } else {
      _sliderSettingsFuture = _repository.getFeaturedSliderSettings();
    }
    
    // 5. Breaking & News Lists
    _loadBreakingTitles(useCache: true);
    _loadInitialNews(useCache: true);
  }

  Future<void> _loadBreakingTitles({bool forceRefresh = false, bool useCache = false}) async {
    if (useCache && !forceRefresh) {
       final cached = _repository.getCachedBreakingNewsTitles(languageCode: _currentLanguageCode);
       if (cached != null) {
          setState(() => _breakingTitles = cached);
          // Fetch fresh in background
          _loadBreakingTitles(forceRefresh: true);
          return;
       }
    }

    try {
      final titles = await _repository.getActiveBreakingNewsTitles(
        languageCode: _currentLanguageCode,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;
      setState(() => _breakingTitles = titles);
    } catch (_) {
      if (!mounted) return;
      // Keep existing if any, or empty
      if (_breakingTitles.isEmpty) {
         setState(() => _breakingTitles = const []);
      }
    }
  }

  Future<void> _loadInitialNews({bool forceRefresh = false, bool useCache = false}) async {
    // 1. Try Sync Cache
    if (useCache && !forceRefresh) {
      final cached = _repository.getCachedLatestNews(
        languageCode: _currentLanguageCode,
        limit: _pageSize,
        offset: 0,
      );
      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _latestNews = cached;
          _offset = cached.length;
          _isInitialNewsLoading = false;
          _hasMoreNews = true;
        });
        // Fetch fresh in background
        _loadInitialNews(forceRefresh: true);
        return;
      }
    }

    // 2. Regular Load / Refresh (Silent if we have data)
    if (forceRefresh && _latestNews.isNotEmpty) {
       try {
         final items = await _repository.getLatestNews(
           languageCode: _currentLanguageCode,
           limit: _pageSize,
           offset: 0,
           forceRefresh: true,
         );
         if (!mounted) return;
         setState(() {
           _latestNews = items;
           _offset = items.length;
           _hasMoreNews = items.length == _pageSize;
           _isInitialNewsLoading = false;
         });
       } catch (_) {
         // Ignore silent refresh errors, keep showing cache
       }
       return;
    }

    // Standard loading with spinner (First load, no cache)
    setState(() {
      _isInitialNewsLoading = true;
      _isLoadingMore = false;
      _offset = 0;
      _hasMoreNews = true;
      _latestNews = const [];
    });

    await _loadMoreNews(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() => _isInitialNewsLoading = false);
  }



  Future<void> _loadMoreNews({bool forceRefresh = false}) async {
    if (_isLoadingMore || !_hasMoreNews) return;

    setState(() => _isLoadingMore = true);

    try {
      final items = await _repository.getLatestNews(
        languageCode: _currentLanguageCode,
        limit: _pageSize,
        offset: _offset,
        forceRefresh: forceRefresh,
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

  Future<void> _onCategorySelected(int? categoryId, {bool forceRefresh = false}) async {
    final nextCategory = categoryId == null
        ? null
        : (_selectedCategoryId == categoryId ? null : categoryId);
    setState(() => _selectedCategoryId = nextCategory);

    if (nextCategory == null) {
      setState(() {
        _categoryNews = const [];
        _isCategoryNewsLoading = false;
      });
      return;
    }

    setState(() {
      _isCategoryNewsLoading = true;
      _categoryNews = const [];
    });

    try {
      final items = await _repository.getLatestNews(
        languageCode: _currentLanguageCode,
        limit: 20,
        offset: 0,
        categoryId: nextCategory,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _categoryNews = items;
      });
    } finally {
      if (mounted) {
        setState(() => _isCategoryNewsLoading = false);
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _categoriesFuture = _repository.getCategories(
        languageCode: _currentLanguageCode,
        forceRefresh: true,
      );
      _featuredFuture = _repository.getFeaturedNews(
        languageCode: _currentLanguageCode,
        limit: 5,
        forceRefresh: true,
      );
      _videoCategoriesFuture = _mediaRepository.getVideoCategories(forceRefresh: true);
      _sliderSettingsFuture = _repository.getFeaturedSliderSettings(forceRefresh: true);
    });

    await _loadBreakingTitles(forceRefresh: true);

    await _loadInitialNews(forceRefresh: true);
    if (_selectedCategoryId != null) {
      await _onCategorySelected(_selectedCategoryId, forceRefresh: true);
    }

    await Future.wait<void>([
      _categoriesFuture.then((_) => null),
      _featuredFuture.then((_) => null),
      _videoCategoriesFuture.then((_) => null),
      _sliderSettingsFuture.then((_) => null),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope(
      canPop: _selectedCategoryId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_selectedCategoryId != null) {
          _onCategorySelected(null);
        }
      },
      child: Scaffold(
        drawer: const HomeDrawer(),
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'assets/images/logo.webp',
                height: 34,
                fit: BoxFit.contain,
              ),
            ],
          ),
          bottom: _breakingTitles.isEmpty
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(36),
                  child: BreakingTicker(
                    titles: _breakingTitles,
                    margin: EdgeInsets.zero,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
          actions: [
            IconButton(
              onPressed: () => showSearch<void>(
                context: context,
                delegate: _NewsSearchDelegate(
                  repository: _repository,
                  languageCode: _currentLanguageCode,
                ),
              ),
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
            if (_selectedCategoryId != null) ...[
              SectionTitle(title: l10n.latestNews),
              if (_isCategoryNewsLoading)
                Column(children: List.generate(4, (_) => const NewsCardShimmer()))
              else if (_categoryNews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(l10n.noNewsNow),
                )
              else
                Column(
                  children: _categoryNews.map((item) => NewsCard(news: item)).toList(),
                ),
            ],
            if (_selectedCategoryId == null) ...[
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.videos,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<VideoCategoryModel>>(
              future: _videoCategoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => const ShimmerLoading(
                        width: 180,
                        height: 120,
                        borderRadius: 14,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(l10n.failedLoadVideos(snapshot.error.toString())),
                  );
                }

                final categories = snapshot.data ?? const <VideoCategoryModel>[];
                if (categories.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(l10n.noVideosNow),
                  );
                }

                return SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final hasCover =
                          item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty;
                      return SizedBox(
                        width: 180,
                        child: Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideosScreen(
                                    categoryId: item.id,
                                    categoryName: item.name,
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (hasCover)
                                  Image.network(
                                    item.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.video_library_rounded,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.video_library_rounded,
                                      size: 30,
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.05),
                                          Colors.black.withValues(alpha: 0.6),
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      item.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsSearchDelegate extends SearchDelegate<void> {
  _NewsSearchDelegate({
    required HomeRepository repository,
    required String languageCode,
  })  : _repository = repository,
        _languageCode = languageCode;

  final HomeRepository _repository;
  final String _languageCode;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _NewsSearchResults(
      query: query,
      repository: _repository,
      languageCode: _languageCode,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _NewsSearchResults(
      query: query,
      repository: _repository,
      languageCode: _languageCode,
    );
  }
}

class _NewsSearchResults extends StatelessWidget {
  const _NewsSearchResults({
    required this.query,
    required this.repository,
    required this.languageCode,
  });

  final String query;
  final HomeRepository repository;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return Center(
        child: Text(
          l10n.search,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return FutureBuilder<List<NewsModel>>(
      future: repository.getLatestNews(
        languageCode: languageCode,
        limit: 50,
        searchQuery: normalizedQuery,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(snapshot.error.toString()),
          );
        }

        final items = snapshot.data ?? const <NewsModel>[];
        if (items.isEmpty) {
          return Center(child: Text(l10n.noNewsNow));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return NewsCard(news: items[index]);
          },
        );
      },
    );
  }
}
