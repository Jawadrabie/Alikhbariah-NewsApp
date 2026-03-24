import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  bool _isMissingNameEnColumnError(Object error) {
    if (error is! PostgrestException) return false;
    final message = error.message.toLowerCase();
    return message.contains("name_en") && message.contains("does not exist");
  }

  String _slugify(String value) {
    final lower = value.toLowerCase().trim();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9\\s-]'), ' ');
    final collapsed = cleaned.replaceAll(RegExp(r'\\s+'), '-');
    final normalized = collapsed.replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return normalized;
  }

  String _buildAutoSlug(Location location) {
    final base = (location.nameEn ?? location.name).trim();
    final normalized = _slugify(base);
    if (normalized.isNotEmpty) {
      return normalized;
    }
    return 'location-${DateTime.now().millisecondsSinceEpoch}';
  }

  Map<String, dynamic> _buildPayload(Location location, {required bool includeNameEn}) {
    final payload = <String, dynamic>{
      'name': location.name.trim(),
      'slug': (location.slug == null || location.slug!.trim().isEmpty)
          ? _buildAutoSlug(location)
          : location.slug!.trim(),
    };

    if (includeNameEn) {
      payload['name_en'] = location.nameEn?.trim().isEmpty == true
          ? null
          : location.nameEn?.trim();
    }

    return payload;
  }

  Future<List<Location>> getLocations() async {
    try {
      final response = await _supabase
          .from('locations')
          .select('id,name,name_en,slug')
          .order('id', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }
      return data.map((json) => Location.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      if (!_isMissingNameEnColumnError(e)) {
        debugPrint('Error fetching locations: $e');
        rethrow;
      }

      final fallbackResponse = await _supabase
          .from('locations')
          .select('id,name,slug')
          .order('id', ascending: false);
      final data = fallbackResponse as List<dynamic>;
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
      final data = _buildPayload(location, includeNameEn: true);
      await _supabase.from('locations').insert(data);
    } on PostgrestException catch (e) {
      if (!_isMissingNameEnColumnError(e)) {
        debugPrint('Error creating locations: $e');
        rethrow;
      }

      final fallback = _buildPayload(location, includeNameEn: false);
      await _supabase.from('locations').insert(fallback);
    } catch (e) {
      debugPrint('Error creating locations: $e');
      rethrow;
    }
  }

  Future<void> updateLocation(Location location) async {
    try {
      final data = _buildPayload(location, includeNameEn: true);
      await _supabase.from('locations').update(data).eq('id', _idValue(location.id));
    } on PostgrestException catch (e) {
      if (!_isMissingNameEnColumnError(e)) {
        debugPrint('Error updating locations: $e');
        rethrow;
      }

      final fallback = _buildPayload(location, includeNameEn: false);
      await _supabase.from('locations').update(fallback).eq('id', _idValue(location.id));
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
