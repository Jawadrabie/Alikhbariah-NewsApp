// ignore_for_file: invalid_use_of_protected_member

part of 'news_details_screen.dart';

extension _NewsDetailsScreenLogic on _NewsDetailsScreenState {
  Future<void> _loadBookmarkState() async {
    final bookmarked = await _bookmarkService.isBookmarked(widget.news.id);
    if (!mounted) return;
    setState(() {
      _isBookmarked = bookmarked;
      _bookmarkLoading = false;
    });
  }

  Future<void> _resolveLocationName() async {
    final locationId = widget.news.locationId;
    if (locationId == null || _locationLoading) return;

    setState(() => _locationLoading = true);
    try {
      final response =
          await Supabase.instance.client
              .from('locations')
              .select('name, name_en')
              .eq('id', locationId)
              .maybeSingle();

      if (!mounted || response == null) return;

      final nameAr = (response['name'] as String?)?.trim();
      final nameEn = (response['name_en'] as String?)?.trim();
      final resolvedName =
          _currentLanguageCode == 'en'
              ? ((nameEn != null && nameEn.isNotEmpty) ? nameEn : nameAr)
              : ((nameAr != null && nameAr.isNotEmpty) ? nameAr : nameEn);

      if (!mounted) return;
      setState(() => _resolvedLocationName = resolvedName);
    } catch (_) {
      // Ignore location lookup errors and keep the page usable.
    } finally {
      if (mounted) {
        setState(() => _locationLoading = false);
      }
    }
  }

  List<NewsModel> _filterRelatedNews(List<NewsModel> items) {
    return items.where((item) => item.id != widget.news.id).take(5).toList();
  }

  List<NewsModel> _getCachedRelatedNews() {
    final cachedByCategory =
        widget.news.categoryId == null
            ? const <NewsModel>[]
            : _filterRelatedNews(
              _homeRepository.getCachedLatestNews(
                    languageCode: _currentLanguageCode,
                    limit: 10,
                    categoryId: widget.news.categoryId,
                  ) ??
                  const <NewsModel>[],
            );

    if (cachedByCategory.isNotEmpty) {
      return cachedByCategory;
    }

    return _filterRelatedNews(
      _homeRepository.getCachedLatestNews(
            languageCode: _currentLanguageCode,
            limit: 10,
          ) ??
          const <NewsModel>[],
    );
  }

  Future<List<NewsModel>> _fetchRelatedNews() async {
    if (widget.news.categoryId != null) {
      final byCategory = await _homeRepository.getLatestNews(
        languageCode: _currentLanguageCode,
        limit: 10,
        categoryId: widget.news.categoryId,
      );

      final filteredByCategory = _filterRelatedNews(byCategory);
      if (filteredByCategory.isNotEmpty) {
        return filteredByCategory;
      }
    }

    final fallbackLatest = await _homeRepository.getLatestNews(
      languageCode: _currentLanguageCode,
      limit: 10,
    );
    return _filterRelatedNews(fallbackLatest);
  }

  Future<void> _loadRelatedNews({bool useCache = false}) async {
    final cached = useCache ? _getCachedRelatedNews() : const <NewsModel>[];
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _relatedNews = cached;
        _relatedLoading = false;
      });
      _warmImageUrls(cached.map((item) => item.imageUrl));
    }

    final hadVisibleRelated = cached.isNotEmpty || _relatedNews.isNotEmpty;

    if (!mounted) return;
    if (!hadVisibleRelated) {
      setState(() => _relatedLoading = true);
    }

    try {
      final related = await _fetchRelatedNews();

      if (!mounted) return;
      setState(() {
        _relatedNews = related;
        _relatedLoading = false;
      });
      _warmImageUrls(related.map((item) => item.imageUrl));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (!hadVisibleRelated) {
          _relatedNews = const [];
        }
        _relatedLoading = false;
      });
    }
  }

  void _warmImageUrls(Iterable<String?> urls) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ImagePrefetchGuard.warmUrls(context, urls, maxUrls: 4);
    });
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < 30.0) _fontSize += 2.0;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 12.0) _fontSize -= 2.0;
    });
  }

  Future<void> _shareArticle() async {
    final title = widget.news.title;
    final url = 'https://newsapp.example.com/news/${widget.news.id}';
    await SharePlus.instance.share(ShareParams(text: '$title\n\n$url'));
  }

  Future<void> _toggleBookmark() async {
    final l10n = context.l10n;
    final nowBookmarked = await _bookmarkService.toggleBookmark(widget.news);
    if (!mounted) return;

    setState(() {
      _isBookmarked = nowBookmarked;
      _bookmarkLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowBookmarked ? l10n.newsSavedLocally : l10n.newsRemovedFromSaved,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
