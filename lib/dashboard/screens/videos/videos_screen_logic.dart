// ignore_for_file: invalid_use_of_protected_member

part of 'videos_screen.dart';

extension _VideosScreenLogic on _VideosScreenState {
  int _nextVideoOrderIndex(List<VideoItem> videos) {
    if (videos.isEmpty) return 1;
    final maxOrder = videos
        .map((item) => item.orderIndex)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  Future<int> _nextVideoOrderIndexForScope({
    String? programId,
    String? categoryId,
  }) async {
    final videos = await _service.getVideos(
      programId: programId,
      categoryId: categoryId,
    );
    return _nextVideoOrderIndex(videos);
  }

  Future<List<Category>> _loadCategoriesWithCounts() async {
    final categories = await _categoryService.getCategories(type: 'video');
    final futures = categories.map((c) async {
      try {
        final videos = await _service.getVideos(categoryId: c.id);
        return Category(
          id: c.id,
          name: c.name,
          nameEn: c.nameEn,
          slug: c.slug,
          coverImageUrl: c.coverImageUrl,
          orderIndex: c.orderIndex,
          type: c.type,
          videoCount: videos.length,
        );
      } catch (_) {
        return Category(
          id: c.id,
          name: c.name,
          nameEn: c.nameEn,
          slug: c.slug,
          coverImageUrl: c.coverImageUrl,
          orderIndex: c.orderIndex,
          type: c.type,
          videoCount: 0,
        );
      }
    });

    return await Future.wait(futures);
  }

  void _reload() {
    setState(() {
      _future = _service.getVideos(
        programId: widget.programId,
        categoryId: widget.categoryId ?? _selectedCategoryId,
      );
      if (widget.programId == null && widget.categoryId == null) {
        _categoriesWithCountsFuture = _loadCategoriesWithCounts();
      }
    });
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await _categoryService.deleteCategory(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_category')}: $e',
      );
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _service.deleteVideo(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_video')}: $e',
      );
    }
  }
}
