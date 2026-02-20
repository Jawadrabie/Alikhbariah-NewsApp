import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  Future<List<Location>> getLocations() async {
    try {
      final response = await _supabase.from('locations').select();
      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((json) => Location.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      rethrow;
    }
  }

  Future<void> createLocation(Location location) async {
    try {
      final data = Map<String, dynamic>.from(location.toJson())..remove('id');
      await _supabase.from('locations').insert(data);
    } catch (e) {
      debugPrint('Error creating locations: $e');
      rethrow;
    }
  }

  Future<void> updateLocation(Location location) async {
    try {
      final data = Map<String, dynamic>.from(location.toJson())..remove('id');
      await _supabase.from('locations').update(data).eq('id', _idValue(location.id));
    } catch (e) {
      debugPrint('Error updating locations: $e');
      rethrow;
    }
  }

  Future<void> deleteLocation(String id) async {
    try {
      await _supabase.from('locations').delete().eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error deleting locations: $e');
      rethrow;
    }
  }
}
