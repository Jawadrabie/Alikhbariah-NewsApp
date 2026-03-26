// ignore_for_file: invalid_use_of_protected_member

part of 'categories_screen.dart';

extension _CategoriesScreenLogic on _CategoriesScreenState {
  String _normalizeCategoryType(String? type) {
    switch ((type ?? '').trim().toLowerCase()) {
      case 'video':
        return 'video';
      case 'program':
        return 'program';
      case 'news':
      default:
        return 'news';
    }
  }

  int _nextOrderIndexForType(List<Category> categories, String type) {
    final matching = categories.where((item) => item.type == type).toList();
    if (matching.isEmpty) return 1;
    final maxOrder = matching
        .map((item) => item.orderIndex)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  void _reload() {
    setState(() {
      _future = _loadData();
    });
  }

  Future<List<Category>> _loadData() async {
    return _service.getCategories();
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
