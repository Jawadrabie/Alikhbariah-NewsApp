// ignore_for_file: invalid_use_of_protected_member

part of 'home_screen.dart';

extension _HomeScreenDataLoading on _HomeScreenState {
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
    _warmNewsImagesFromFuture(_featuredFuture);

    _sliderSettingsFuture = _seedFutureFromCache(
      cachedValue: _repository.getCachedFeaturedSliderSettings(),
      assign: (future) => _sliderSettingsFuture = future,
      load:
          (forceRefresh) =>
              _repository.getFeaturedSliderSettings(forceRefresh: forceRefresh),
    );
    _warmVideoCategoryImagesFromFuture(_videoCategoriesFuture);

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

  void _warmNewsImagesFromFuture(Future<List<NewsModel>> future) {
    future.then(_warmNewsImages).catchError((_) {});
  }

  void _warmVideoCategoryImagesFromFuture(
    Future<List<VideoCategoryModel>> future,
  ) {
    future.then(_warmVideoCategoryImages).catchError((_) {});
  }

  void _warmNewsImages(Iterable<NewsModel> items) {
    _warmImageUrls(items.map((item) => item.imageUrl));
  }

  void _warmVideoCategoryImages(Iterable<VideoCategoryModel> items) {
    _warmImageUrls(items.map((item) => item.coverImageUrl));
  }

  void _warmImageUrls(Iterable<String?> urls) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ImagePrefetchGuard.warmUrls(context, urls, maxUrls: 6);
    });
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
}
