import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../media/data/models/video_category_model.dart';
import '../../../media/data/repositories/media_repository.dart';
import '../../../media/presentation/screens/videos_screen.dart';
import '../../../news/presentation/screens/saved_news_screen.dart';
import '../../data/models/category_model.dart';
import '../../data/models/breaking_news_headline_model.dart';
import '../../data/models/featured_slider_settings_model.dart';
import '../../data/models/news_model.dart';
import '../../data/repositories/home_repository.dart';
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
  static const int _pageSize = 10;

  final HomeRepository _repository = HomeRepository();
  final MediaRepository _mediaRepository = MediaRepository();
  final ScrollController _scrollController = ScrollController();

  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<NewsModel>> _featuredFuture;
  late Future<List<VideoCategoryModel>> _videoCategoriesFuture;
  late Future<FeaturedSliderSettingsModel> _sliderSettingsFuture;

  List<NewsModel> _latestNews = const [];
  List<NewsModel> _categoryNews = const [];
  List<BreakingNewsHeadlineModel> _breakingHeadlines = const [];
  final Set<int> _trackedBreakingViewIds = <int>{};
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
    final languageCode =
        Localizations.localeOf(context).languageCode.toLowerCase();

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
    _categoriesFuture = _seedFutureFromCache(
      cachedValue: _repository.getCachedCategories(
        languageCode: _currentLanguageCode,
      ),
      assign: (future) => _categoriesFuture = future,
      load:
          (forceRefresh) => _repository.getCategories(
            languageCode: _currentLanguageCode,
            forceRefresh: forceRefresh,
          ),
    );

    _featuredFuture = _seedFutureFromCache(
      cachedValue: _repository.getCachedFeaturedNews(
        languageCode: _currentLanguageCode,
        limit: 5,
      ),
      assign: (future) => _featuredFuture = future,
      load:
          (forceRefresh) => _repository.getFeaturedNews(
            languageCode: _currentLanguageCode,
            limit: 5,
            forceRefresh: forceRefresh,
          ),
    );

    _videoCategoriesFuture = _seedFutureFromCache(
      cachedValue: _mediaRepository.getCachedVideoCategories(
        languageCode: _currentLanguageCode,
      ),
      assign: (future) => _videoCategoriesFuture = future,
      load:
          (forceRefresh) => _mediaRepository.getVideoCategories(
            languageCode: _currentLanguageCode,
            forceRefresh: forceRefresh,
          ),
    );

    _sliderSettingsFuture = _seedFutureFromCache(
      cachedValue: _repository.getCachedFeaturedSliderSettings(),
      assign: (future) => _sliderSettingsFuture = future,
      load:
          (forceRefresh) =>
              _repository.getFeaturedSliderSettings(forceRefresh: forceRefresh),
    );

    _loadBreakingTitles(useCache: true);
    _loadInitialNews(useCache: true);
  }

  Future<T> _seedFutureFromCache<T>({
    required T? cachedValue,
    required void Function(Future<T> future) assign,
    required Future<T> Function(bool forceRefresh) load,
  }) {
    if (cachedValue != null) {
      load(true).then((fresh) {
        if (!mounted) return;
        setState(() {
          assign(Future.value(fresh));
        });
      });
      return Future.value(cachedValue);
    }

    return load(false);
  }

  Future<void> _loadBreakingTitles({
    bool forceRefresh = false,
    bool useCache = false,
  }) async {
    if (useCache && !forceRefresh) {
      final cached = _repository.getCachedActiveBreakingNewsHeadlines(
        languageCode: _currentLanguageCode,
      );
      if (cached != null) {
        setState(() => _breakingHeadlines = cached);
        _registerBreakingViews(cached);
        _loadBreakingTitles(forceRefresh: true);
        return;
      }
    }

    try {
      final headlines = await _repository.getActiveBreakingNewsHeadlines(
        languageCode: _currentLanguageCode,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;
      setState(() => _breakingHeadlines = headlines);
      _registerBreakingViews(headlines);
    } catch (_) {
      if (!mounted || _breakingHeadlines.isNotEmpty) return;
      setState(() => _breakingHeadlines = const []);
    }
  }

  Future<void> _registerBreakingViews(
    List<BreakingNewsHeadlineModel> headlines,
  ) async {
    final pendingIds =
        headlines
            .map((item) => item.id)
            .where((id) => !_trackedBreakingViewIds.contains(id))
            .toList();

    if (pendingIds.isEmpty) return;

    _trackedBreakingViewIds.addAll(pendingIds);

    try {
      await Future.wait<void>(
        pendingIds.map(_repository.incrementBreakingNewsViewCount),
      );
    } catch (_) {}
  }

  Future<void> _loadInitialNews({
    bool forceRefresh = false,
    bool useCache = false,
  }) async {
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
        _loadInitialNews(forceRefresh: true);
        return;
      }
    }

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
      } catch (_) {}

      return;
    }

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

  Future<void> _onCategorySelected(
    int? categoryId, {
    bool forceRefresh = false,
  }) async {
    final nextCategory =
        categoryId == null
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
      setState(() => _categoryNews = items);
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
      _videoCategoriesFuture = _mediaRepository.getVideoCategories(
        languageCode: _currentLanguageCode,
        forceRefresh: true,
      );
      _sliderSettingsFuture = _repository.getFeaturedSliderSettings(
        forceRefresh: true,
      );
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

  void _openSavedNews() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedNewsScreen()),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      iconTheme: IconThemeData(color: scheme.onSurface),
      actionsIconTheme: IconThemeData(color: scheme.onSurface),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset(
            'assets/images/logo.webp',
            height: 38,
            fit: BoxFit.contain,
          ),
        ],
      ),
      bottom:
          _breakingHeadlines.isEmpty
              ? null
              : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: _BreakingTickerHeader(
                  titles: _breakingHeadlines.map((item) => item.title).toList(),
                ),
              ),
      actions: [
        IconButton(
          onPressed:
              () => showSearch<void>(
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
          onPressed: _openSavedNews,
          icon: const Icon(Icons.bookmark_outline_rounded),
          tooltip: l10n.savedNews,
        ),
        IconButton(
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: l10n.refresh,
        ),
      ],
    );
  }

  List<Widget> _buildContent(AppLocalizations l10n) {
    final content = <Widget>[
      _HomeCategoriesStrip(
        future: _categoriesFuture,
        selectedCategoryId: _selectedCategoryId,
        onCategorySelected: _onCategorySelected,
      ),
    ];

    if (_selectedCategoryId != null) {
      content.add(
        _CategoryNewsSection(
          title: l10n.latestNews,
          isLoading: _isCategoryNewsLoading,
          items: _categoryNews,
          emptyText: l10n.noNewsNow,
        ),
      );
      return content;
    }

    content.addAll([
      _FeaturedNewsSection(
        newsFuture: _featuredFuture,
        settingsFuture: _sliderSettingsFuture,
      ),
      _VideoCategoriesSection(
        future: _videoCategoriesFuture,
        title: l10n.videos,
      ),
      _LatestNewsSection(
        title: l10n.latestNews,
        items: _latestNews,
        isInitialLoading: _isInitialNewsLoading,
        isLoadingMore: _isLoadingMore,
        hasMore: _hasMoreNews,
        emptyText: l10n.noNewsNow,
        allShownText: l10n.allNewsShown,
      ),
      const SizedBox(height: 12),
    ]);

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope(
      canPop: _selectedCategoryId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _selectedCategoryId == null) return;
        _onCategorySelected(null);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: const HomeDrawer(),
        appBar: _buildAppBar(l10n),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            controller: _scrollController,
            children: _buildContent(l10n),
          ),
        ),
      ),
    );
  }
}

class _BreakingTickerHeader extends StatelessWidget {
  const _BreakingTickerHeader({required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: BreakingTicker(
        titles: titles,
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}

class _HomeCategoriesStrip extends StatelessWidget {
  const _HomeCategoriesStrip({
    required this.future,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final Future<List<CategoryModel>> future;
  final int? selectedCategoryId;
  final Future<void> Function(int? categoryId, {bool forceRefresh})
  onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<List<CategoryModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 52, child: CategoryChipsShimmer());
        }

        if (snapshot.hasError) {
          return _SectionMessage(
            text: l10n.failedLoadCategories(snapshot.error.toString()),
          );
        }

        return CategoryChips(
          categories: snapshot.data ?? const [],
          selectedCategoryId: selectedCategoryId,
          onCategorySelected: onCategorySelected,
        );
      },
    );
  }
}

class _CategoryNewsSection extends StatelessWidget {
  const _CategoryNewsSection({
    required this.title,
    required this.isLoading,
    required this.items,
    required this.emptyText,
  });

  final String title;
  final bool isLoading;
  final List<NewsModel> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: title),
        if (isLoading)
          Column(children: List.generate(4, (_) => const NewsCardShimmer()))
        else if (items.isEmpty)
          _SectionMessage(text: emptyText)
        else
          _NewsList(items: items),
      ],
    );
  }
}

class _FeaturedNewsSection extends StatelessWidget {
  const _FeaturedNewsSection({
    required this.newsFuture,
    required this.settingsFuture,
  });

  final Future<List<NewsModel>> newsFuture;
  final Future<FeaturedSliderSettingsModel> settingsFuture;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<List<NewsModel>>(
      future: newsFuture,
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
          return _SectionMessage(
            text: l10n.failedLoadFeaturedNews(snapshot.error.toString()),
          );
        }

        return FutureBuilder<FeaturedSliderSettingsModel>(
          future: settingsFuture,
          builder: (context, settingsSnapshot) {
            final settings =
                settingsSnapshot.data ??
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
    );
  }
}

class _VideoCategoriesSection extends StatelessWidget {
  const _VideoCategoriesSection({required this.future, required this.title});

  final Future<List<VideoCategoryModel>> future;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<VideoCategoryModel>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder:
                      (context, index) => const ShimmerLoading(
                        width: 180,
                        height: 120,
                        borderRadius: 14,
                      ),
                ),
              );
            }

            if (snapshot.hasError) {
              return _SectionMessage(
                text: l10n.failedLoadVideos(snapshot.error.toString()),
              );
            }

            final categories = snapshot.data ?? const <VideoCategoryModel>[];
            if (categories.isEmpty) {
              return _SectionMessage(text: l10n.noVideosNow);
            }

            return SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder:
                    (context, index) =>
                        _VideoCategoryCard(category: categories[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VideoCategoryCard extends StatelessWidget {
  const _VideoCategoryCard({required this.category});

  final VideoCategoryModel category;

  @override
  Widget build(BuildContext context) {
    final hasCover =
        category.coverImageUrl != null && category.coverImageUrl!.isNotEmpty;
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.video_library_rounded, size: 30),
    );

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
                builder:
                    (_) => VideosScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasCover)
                CachedNetworkImage(
                  imageUrl: category.coverImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => placeholder,
                  errorWidget: (_, __, ___) => placeholder,
                )
              else
                placeholder,
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
                    category.name,
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
  }
}

class _LatestNewsSection extends StatelessWidget {
  const _LatestNewsSection({
    required this.title,
    required this.items,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.emptyText,
    required this.allShownText,
  });

  final String title;
  final List<NewsModel> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String emptyText;
  final String allShownText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: title),
        if (isInitialLoading)
          Column(children: List.generate(5, (_) => const NewsCardShimmer()))
        else if (items.isEmpty)
          _SectionMessage(text: emptyText)
        else
          _NewsList(items: items),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        if (!isInitialLoading && !hasMore && items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                allShownText,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ),
      ],
    );
  }
}

class _NewsList extends StatelessWidget {
  const _NewsList({required this.items});

  final List<NewsModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(children: items.map((item) => NewsCard(news: item)).toList());
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text),
    );
  }
}

class _NewsSearchDelegate extends SearchDelegate<void> {
  _NewsSearchDelegate({
    required HomeRepository repository,
    required String languageCode,
  }) : _repository = repository,
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
        child: Text(l10n.search, style: Theme.of(context).textTheme.bodyMedium),
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
