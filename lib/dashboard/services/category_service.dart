import 'package:flutter/foundation.dart' hide Category;
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  Future<List<Category>> getCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> createCategory(Category category) async {
    try {
      final data = Map<String, dynamic>.from(category.toJson())..remove('id');
      await _supabase.from('categories').insert(data);
    } catch (e) {
      debugPrint('Error creating categories: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      final data = Map<String, dynamic>.from(category.toJson())..remove('id');
      await _supabase.from('categories').update(data).eq('id', _idValue(category.id));
    } catch (e) {
      debugPrint('Error updating categories: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error deleting categories: $e');
      rethrow;
    }
  }
}
