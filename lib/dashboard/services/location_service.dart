import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final _supabase = Supabase.instance.client;

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
}
