// ignore_for_file: invalid_use_of_protected_member

part of 'home_screen.dart';

extension _HomeScreenNewsLoading on _HomeScreenState {
  Future<void> _loadInitialNews({
    bool forceRefresh = false,
    bool useCache = false,
  }) async {
    if (useCache && !forceRefresh) {
      final cached = _repository.getCachedLatestNews(
        languageCode: _currentLanguageCode,
        limit: _HomeScreenState._pageSize,
        offset: 0,
      );

      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _latestNews = cached;
          _offset = cached.length;
          _isInitialNewsLoading = false;
          _hasMoreNews = true;
        });
        _warmNewsImages(cached);
        _loadInitialNews(forceRefresh: true);
        return;
      }
    }

    if (forceRefresh && _latestNews.isNotEmpty) {
      try {
        final items = await _repository.getLatestNews(
          languageCode: _currentLanguageCode,
          limit: _HomeScreenState._pageSize,
          offset: 0,
          forceRefresh: true,
        );

        if (!mounted) return;
        setState(() {
          _latestNews = items;
          _offset = items.length;
          _hasMoreNews = items.length == _HomeScreenState._pageSize;
          _isInitialNewsLoading = false;
        });
        _warmNewsImages(items);
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
        limit: _HomeScreenState._pageSize,
        offset: _offset,
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;
      setState(() {
        _latestNews = [..._latestNews, ...items];
        _offset += items.length;
        _hasMoreNews = items.length == _HomeScreenState._pageSize;
      });
      _warmNewsImages(items);
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

    final cached = _repository.getCachedLatestNews(
      languageCode: _currentLanguageCode,
      limit: 20,
      offset: 0,
      categoryId: nextCategory,
    );

    setState(() {
      _isCategoryNewsLoading = cached == null || cached.isEmpty;
      _categoryNews = cached ?? const [];
    });
    if (cached != null) {
      _warmNewsImages(cached);
    }

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
      _warmNewsImages(items);
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
      _latestVideosFuture = _mediaRepository.getVideos(
        languageCode: _currentLanguageCode,
        limit: _HomeScreenState._pageSize,
        forceRefresh: true,
      );
      _sliderSettingsFuture = _repository.getFeaturedSliderSettings(
        forceRefresh: true,
      );
    });
    _warmNewsImagesFromFuture(_featuredFuture);
    _warmVideoImagesFromFuture(_latestVideosFuture);

    await _loadBreakingTitles(forceRefresh: true);
    await _loadInitialNews(forceRefresh: true);

    if (_selectedCategoryId != null) {
      await _onCategorySelected(_selectedCategoryId, forceRefresh: true);
    }

    await Future.wait<void>([
      _categoriesFuture.then((_) => null),
      _featuredFuture.then((_) => null),
      _latestVideosFuture.then((_) => null),
      _sliderSettingsFuture.then((_) => null),
    ]);
  }
}
