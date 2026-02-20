import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/program.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgramsService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  Future<List<Program>> getPrograms() async {
    try {
      final response = await _supabase
          .from('programs')
          .select()
          .order('order_index', ascending: true)
          .order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map((json) => Program.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching programs: $e');
      rethrow;
    }
  }

  Future<void> createProgram(Program item) async {
    try {
      final data = Map<String, dynamic>.from(item.toJson())..remove('id');
      await _supabase.from('programs').insert(data);
    } catch (e) {
      debugPrint('Error creating program: $e');
      rethrow;
    }
  }

  Future<void> updateProgram(Program item) async {
    try {
      final data = Map<String, dynamic>.from(item.toJson())..remove('id');
      await _supabase.from('programs').update(data).eq('id', _idValue(item.id));
    } catch (e) {
      debugPrint('Error updating program: $e');
      rethrow;
    }
  }

  Future<void> deleteProgram(String id) async {
    try {
      await _supabase.from('programs').delete().eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error deleting program: $e');
      rethrow;
    }
  }
}
