import 'package:flutter/foundation.dart' hide Category;
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final _supabase = Supabase.instance.client;
  static final Map<String, List<Category>> _categoriesCache = {};
  static final Map<String, DateTime> _categoriesCacheAt = {};
  static const Duration _cacheTtl = Duration(seconds: 45);

  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  bool _isMissingCoverColumnError(Object error) {
    final text = error.toString();
    return text.contains('cover_image_url') && text.contains('42703');
  }

  Future<List<Category>> getCategories({
    String? type,
    bool forceRefresh = false,
  }) async {
    final cacheKey = type ?? 'all';
    final hasFreshCache =
        !forceRefresh &&
        _categoriesCache.containsKey(cacheKey) &&
        _categoriesCacheAt.containsKey(cacheKey) &&
        DateTime.now().difference(_categoriesCacheAt[cacheKey]!) < _cacheTtl;

    if (hasFreshCache) {
      return List<Category>.from(_categoriesCache[cacheKey]!);
    }

    try {
      var query = _supabase
          .from('categories')
          .select('id,name,name_en,slug,cover_image_url,order_index,type');

      if (type != null && type.isNotEmpty) {
        query = query.eq('type', type);
      }

      dynamic response;
      try {
        response = await query.order('order_index', ascending: true);
      } catch (e) {
        if (!_isMissingCoverColumnError(e)) rethrow;

        var fallbackQuery = _supabase
            .from('categories')
            .select('id,name,name_en,slug,order_index,type');
        if (type != null && type.isNotEmpty) {
          fallbackQuery = fallbackQuery.eq('type', type);
        }
        response = await fallbackQuery.order('order_index', ascending: true);
      }

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        _categoriesCache[cacheKey] = const [];
        _categoriesCacheAt[cacheKey] = DateTime.now();
        return [];
      }

      final categories = data.map((json) => Category.fromJson(json)).toList();
      _categoriesCache[cacheKey] = categories;
      _categoriesCacheAt[cacheKey] = DateTime.now();
      return List<Category>.from(categories);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  void _invalidateCategoriesCache() {
    _categoriesCache.clear();
    _categoriesCacheAt.clear();
  }

  String _slugify(String value) {
    final lower = value.trim().toLowerCase();
    final replaced = lower
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return replaced.isEmpty ? 'category' : replaced;
  }

  String _buildAutoSlug(Category category) {
    final base =
        category.nameEn.trim().isNotEmpty ? category.nameEn : category.name;
    final normalized = _slugify(base);
    return '${category.type}-$normalized-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> createCategory(Category category) async {
    try {
      final data = Map<String, dynamic>.from(category.toJson())..remove('id');
      final incomingSlug = data['slug']?.toString().trim();
      if (incomingSlug == null || incomingSlug.isEmpty) {
        data['slug'] = _buildAutoSlug(category);
      }
      try {
        await _supabase.from('categories').insert(data);
      } catch (e) {
        if (!_isMissingCoverColumnError(e)) rethrow;
        data.remove('cover_image_url');
        await _supabase.from('categories').insert(data);
      }

      _invalidateCategoriesCache();
    } catch (e) {
      debugPrint('Error creating categories: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      final data = Map<String, dynamic>.from(category.toJson())..remove('id');
      try {
        await _supabase
            .from('categories')
            .update(data)
            .eq('id', _idValue(category.id));
      } catch (e) {
        if (!_isMissingCoverColumnError(e)) rethrow;
        data.remove('cover_image_url');
        await _supabase
            .from('categories')
            .update(data)
            .eq('id', _idValue(category.id));
      }

      _invalidateCategoriesCache();
    } catch (e) {
      debugPrint('Error updating categories: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', _idValue(id));
      _invalidateCategoriesCache();
    } catch (e) {
      debugPrint('Error deleting categories: $e');
      rethrow;
    }
  }
}
