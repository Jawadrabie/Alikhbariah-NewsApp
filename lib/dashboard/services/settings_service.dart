import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/app_setting.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsService {
  final _supabase = Supabase.instance.client;

  Future<List<AppSetting>> getSettings() async {
    try {
      final response = await _supabase.from('app_settings').select().order('key');
      return (response as List<dynamic>)
          .map((json) => AppSetting.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching settings: $e');
      rethrow;
    }
  }

  Future<void> upsertSetting(AppSetting setting) async {
    try {
      await _supabase.from('app_settings').upsert(setting.toJson());
    } catch (e) {
      debugPrint('Error upserting setting: $e');
      rethrow;
    }
  }

  Future<void> deleteSetting(String key) async {
    try {
      await _supabase.from('app_settings').delete().eq('key', key);
    } catch (e) {
      debugPrint('Error deleting setting: $e');
      rethrow;
    }
  }
}
