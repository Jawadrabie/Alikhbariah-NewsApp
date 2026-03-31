// ignore_for_file: invalid_use_of_protected_member

part of 'videos_screen.dart';

extension _VideosScreenLogic on _VideosScreenState {
  void _initializeFutures() {
    if (widget.programId != null) {
      _videosFuture = _seedFutureFromCache(
        cachedValue: _repository.getCachedVideos(
          languageCode: _currentLanguageCode,
          programId: widget.programId,
        ),
        assign: (future) => _videosFuture = future,
        load:
            (forceRefresh) => _repository.getVideos(
              languageCode: _currentLanguageCode,
              programId: widget.programId,
              forceRefresh: forceRefresh,
            ),
      );
    } else if (widget.categoryId != null) {
      _videosFuture = _seedFutureFromCache(
        cachedValue: _repository.getCachedVideos(
          languageCode: _currentLanguageCode,
          categoryId: widget.categoryId,
        ),
        assign: (future) => _videosFuture = future,
        load:
            (forceRefresh) => _repository.getVideos(
              languageCode: _currentLanguageCode,
              categoryId: widget.categoryId,
              forceRefresh: forceRefresh,
            ),
      );
    } else if (widget.showLatestVideos) {
      _videosFuture = _seedFutureFromCache(
        cachedValue: _repository.getCachedVideos(
          languageCode: _currentLanguageCode,
        ),
        assign: (future) => _videosFuture = future,
        load:
            (forceRefresh) => _repository.getVideos(
              languageCode: _currentLanguageCode,
              forceRefresh: forceRefresh,
            ),
      );
    } else {
      _categoriesFuture = _seedFutureFromCache(
        cachedValue: _repository.getCachedVideoCategories(
          languageCode: _currentLanguageCode,
        ),
        assign: (future) => _categoriesFuture = future,
        load:
            (forceRefresh) => _repository.getVideoCategories(
              languageCode: _currentLanguageCode,
              forceRefresh: forceRefresh,
            ),
      );
    }
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

  String _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    }

    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'] ?? '';
    }

    final segments = uri.pathSegments;
    final index = segments.indexOf('embed');
    if (index != -1 && segments.length > index + 1) {
      return segments[index + 1];
    }

    return '';
  }

  String _thumbnailOf(VideoItemModel item) {
    if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
      return item.thumbnailUrl!;
    }

    final id = _extractYoutubeId(item.youtubeUrl);
    if (id.isEmpty) {
      return '';
    }

    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  String _episodesLabel(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'en' ? 'Episodes' : 'الحلقات';
  }

  void _openEpisodePlayer({
    required List<VideoItemModel> items,
    required int initialIndex,
    required String listTitle,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MediaEpisodePlayerScreen(
              episodes: items,
              initialIndex: initialIndex,
              listTitle: listTitle,
            ),
      ),
    );
  }
}
