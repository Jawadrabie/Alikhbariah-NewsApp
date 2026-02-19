import 'package:flutter/foundation.dart' hide Category;
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final _supabase = Supabase.instance.client;

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
}
