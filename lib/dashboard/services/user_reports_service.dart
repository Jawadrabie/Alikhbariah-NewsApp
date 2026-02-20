import 'package:flutter/foundation.dart';
import 'package:newsappjs/dashboard/models/user_report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserReportsService {
  final _supabase = Supabase.instance.client;
  dynamic _idValue(String id) => int.tryParse(id) ?? id;

  Future<List<UserReport>> getReports() async {
    try {
      final response = await _supabase
          .from('user_reports')
          .select()
          .order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map((json) => UserReport.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user reports: $e');
      rethrow;
    }
  }

  Future<void> updateReviewStatus(String id, bool reviewed) async {
    try {
      await _supabase
          .from('user_reports')
          .update({'is_reviewed': reviewed})
          .eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error updating user report status: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _supabase.from('user_reports').delete().eq('id', _idValue(id));
    } catch (e) {
      debugPrint('Error deleting user report: $e');
      rethrow;
    }
  }
}
