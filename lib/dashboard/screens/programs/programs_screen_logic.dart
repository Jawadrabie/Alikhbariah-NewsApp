// ignore_for_file: invalid_use_of_protected_member

part of 'programs_screen.dart';

extension _ProgramsScreenLogic on _ProgramsScreenState {
  int _nextOrderIndex(List<Category> programs) {
    if (programs.isEmpty) return 1;
    final maxOrder = programs
        .map((item) => item.orderIndex)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  int _nextEpisodeOrderIndex(List<VideoItem> videos) {
    if (videos.isEmpty) return 1;
    final maxOrder = videos
        .map((item) => item.orderIndex)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  void _reload() {
    setState(() {
      _future = _service.getCategories(type: 'program');
    });
  }

  Future<void> _delete(String id) async {
    try {
      await _service.deleteCategory(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_category')}: $e',
      );
    }
  }
}
