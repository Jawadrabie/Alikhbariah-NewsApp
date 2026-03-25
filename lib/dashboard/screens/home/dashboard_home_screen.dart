import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>> _future;

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

  @override
  void initState() {
    super.initState();
    _future = _load();
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

  Widget _kpi(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 240, // consistent width for wrap
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10), // Softer corners
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${t('error')}: ${snapshot.error}'));
          }
          final data = snapshot.data ?? {};
          final latestNews = (data['latestNews'] as List<dynamic>? ?? []);
          final latestBreaking =
              (data['latestBreaking'] as List<dynamic>? ?? []);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = _load();
              });
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(24), // Increased padding
              children: [
                _buildHeader(t),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _kpi(
                      context,
                      t('total_news'),
                      '${data['newsCount'] ?? 0}',
                      Icons.article,
                      scheme.primary,
                    ),
                    _kpi(
                      context,
                      t('featured_news'),
                      '${data['featuredNewsCount'] ?? 0}',
                      Icons.star,
                      scheme.tertiary,
                    ),
                    _kpi(
                      context,
                      t('hidden_news'),
                      '${data['hiddenNewsCount'] ?? 0}',
                      Icons.visibility_off,
                      scheme.outline,
                    ),
                    _kpi(
                      context,
                      t('breaking_items'),
                      '${data['breakingCount'] ?? 0}',
                      Icons.flash_on,
                      scheme.error,
                    ),
                    _kpi(
                      context,
                      t('videos'),
                      '${data['videosCount'] ?? 0}',
                      Icons.play_circle,
                      scheme.secondary,
                    ),
                    _kpi(
                      context,
                      t('programs'),
                      '${data['programsCount'] ?? 0}',
                      Icons.tv,
                      scheme.primaryContainer,
                    ),
                    _kpi(
                      context,
                      t('categories'),
                      '${data['categoriesCount'] ?? 0}',
                      Icons.category,
                      scheme.tertiaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildRecentList(
                        t('latest_news'),
                        latestNews,
                        (item) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.newspaper, color: scheme.primary),
                          ),
                          title: Text(
                            (item['title'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            (item['created_at'] ?? '')
                                .toString()
                                .split('T')
                                .first,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                          trailing:
                              ((item['is_hidden'] ?? false) == true)
                                  ? Chip(
                                    label: Text(
                                      t('hidden'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: scheme.onErrorContainer,
                                      ),
                                    ),
                                    backgroundColor: scheme.errorContainer,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildRecentList(
                        t('latest_breaking_news'),
                        latestBreaking,
                        (item) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.flash_on, color: scheme.error),
                          ),
                          title: Text(
                            (item['title'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            t('from_to')
                                .replaceFirst(
                                  '{start}',
                                  _formatIsoTime(item['start_time']),
                                )
                                .replaceFirst(
                                  '{end}',
                                  _formatIsoTime(item['end_time']),
                                ),
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String Function(String) t) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('dashboard_overview'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('welcome_message'),
          style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => context.push('/dashboard/main-news/add'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(t('add_news')),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.primary,
                side: BorderSide(color: scheme.outline),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => context.push('/dashboard/breaking-news/add'),
              icon: const Icon(Icons.add_alert, size: 18),
              label: Text(t('add_breaking_news')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentList(
    String title,
    List<dynamic> items,
    Widget Function(dynamic) itemBuilder,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No items yet',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder:
                  (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (_, index) => itemBuilder(items[index]),
            ),
        ],
      ),
    );
  }
}
