import 'package:flutter/foundation.dart' hide Category;
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/services/dashboard_translation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final _supabase = Supabase.instance.client;
  final DashboardTranslationService _translationService = DashboardTranslationService();
  static final Map<String, List<Category>> _categoriesCache = {};
  static final Map<String, DateTime> _categoriesCacheAt = {};
  static const Duration _cacheTtl = Duration(seconds: 45);

  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  Future<List<Category>> getCategories({String? type, bool forceRefresh = false}) async {
    final cacheKey = type ?? 'all';
    final hasFreshCache = !forceRefresh &&
        _categoriesCache.containsKey(cacheKey) &&
        _categoriesCacheAt.containsKey(cacheKey) &&
        DateTime.now().difference(_categoriesCacheAt[cacheKey]!) < _cacheTtl;

    if (hasFreshCache) {
      return List<Category>.from(_categoriesCache[cacheKey]!);
    }

    try {
      var query = _supabase
          .from('categories')
          .select('id,name,slug,order_index,type');

      if (type != null && type.isNotEmpty) {
        query = query.eq('type', type);
      }
      
      final response = await query.order('order_index', ascending: true);

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

  Future<void> createCategory(Category category) async {
    try {
      final data = Map<String, dynamic>.from(category.toJson())..remove('id');
      data['name_en'] = await _translationService.translateArToEn(category.name);

      try {
        await _supabase.from('categories').insert(data);
      } on PostgrestException catch (error) {
        if (!error.message.toLowerCase().contains('name_en')) {
          rethrow;
        }
        data.remove('name_en');
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
      data['name_en'] = await _translationService.translateArToEn(category.name);

      try {
        await _supabase.from('categories').update(data).eq('id', _idValue(category.id));
      } on PostgrestException catch (error) {
        if (!error.message.toLowerCase().contains('name_en')) {
          rethrow;
        }
        data.remove('name_en');
        await _supabase.from('categories').update(data).eq('id', _idValue(category.id));
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
