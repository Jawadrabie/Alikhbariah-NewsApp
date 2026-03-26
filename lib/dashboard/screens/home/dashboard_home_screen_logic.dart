part of 'dashboard_home_screen.dart';

extension _DashboardHomeScreenLogic on _DashboardHomeScreenState {
  Future<int> _countRows(String table, {Map<String, dynamic>? equals}) async {
    dynamic listQuery = _supabase.from(table).select('id');
    if (equals != null) {
      for (final entry in equals.entries) {
        listQuery = listQuery.eq(entry.key, entry.value);
      }
    }

    final response = await listQuery as List<dynamic>;
    return response.length;
  }

  String _formatIsoTime(dynamic rawValue) {
    final raw = (rawValue ?? '').toString();
    if (raw.isEmpty) return '--:--';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return '--:--';
    final local = parsed.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(local);
    final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local));
    return '$date $time';
  }

  Future<Map<String, dynamic>> _load() async {
    final results = await Future.wait<dynamic>([
      _supabase
          .from('news')
          .select('id,title,created_at,is_hidden')
          .order('created_at', ascending: false)
          .limit(5),
      _supabase
          .from('breaking_news')
          .select('id,title,start_time,end_time')
          .order('created_at', ascending: false)
          .limit(5),
      _countRows('videos'),
      _countRows('categories', equals: {'type': 'program'}),
      _countRows('categories'),
      _countRows('news'),
      _countRows('news', equals: {'is_hidden': true}),
      _countRows('news', equals: {'is_featured': true}),
    ]);

    final latestNews = results[0] as List<dynamic>;
    final latestBreaking = results[1] as List<dynamic>;
    final videosCount = results[2] as int;
    final programsCount = results[3] as int;
    final categoriesCount = results[4] as int;
    final newsCount = results[5] as int;
    final hiddenCount = results[6] as int;
    final featuredCount = results[7] as int;

    return {
      'newsCount': newsCount,
      'hiddenNewsCount': hiddenCount,
      'featuredNewsCount': featuredCount,
      'breakingCount': latestBreaking.length,
      'videosCount': videosCount,
      'programsCount': programsCount,
      'categoriesCount': categoriesCount,
      'latestNews': latestNews,
      'latestBreaking': latestBreaking,
    };
  }
}
