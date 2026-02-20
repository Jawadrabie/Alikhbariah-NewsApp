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

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final news = await _supabase
        .from('news')
        .select('id,title,created_at,is_hidden')
        .order('created_at', ascending: false)
        .limit(5);

    final breaking = await _supabase
        .from('breaking_news')
        .select('id,title,start_time,end_time')
        .order('created_at', ascending: false)
        .limit(5);

    final videos = await _supabase.from('videos').select('id');
    final programs = await _supabase.from('programs').select('id');
    final categories = await _supabase.from('categories').select('id');

    final allNews = await _supabase.from('news').select('id,is_hidden,is_featured');
    final hiddenCount = (allNews as List<dynamic>)
        .where((e) => (e['is_hidden'] ?? false) == true)
        .length;
    final featuredCount = (allNews)
        .where((e) => (e['is_featured'] ?? false) == true)
        .length;

    return {
      'newsCount': (allNews).length,
      'hiddenNewsCount': hiddenCount,
      'featuredNewsCount': featuredCount,
      'breakingCount': (breaking as List<dynamic>).length,
      'videosCount': (videos as List<dynamic>).length,
      'programsCount': (programs as List<dynamic>).length,
      'categoriesCount': (categories as List<dynamic>).length,
      'latestNews': news,
      'latestBreaking': breaking,
    };
  }

  Widget _kpi(String title, String value, IconData icon, Color color) {
    return Container(
      width: 240, // consistent width for wrap
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Softer shadow
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10), // Softer corners
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B), // Dark slate
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
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

    return Scaffold(
      backgroundColor: Colors.transparent, // Let parent background show
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
          final latestBreaking = (data['latestBreaking'] as List<dynamic>? ?? []);

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
                    _kpi(t('total_news'), '${data['newsCount'] ?? 0}', Icons.article, Colors.blue),
                    _kpi(t('featured_news'), '${data['featuredNewsCount'] ?? 0}', Icons.star, Colors.amber),
                    _kpi(t('hidden_news'), '${data['hiddenNewsCount'] ?? 0}', Icons.visibility_off, Colors.grey),
                    _kpi(t('breaking_items'), '${data['breakingCount'] ?? 0}', Icons.flash_on, Colors.red),
                    _kpi(t('videos'), '${data['videosCount'] ?? 0}', Icons.play_circle, Colors.deepPurple),
                    _kpi(t('programs'), '${data['programsCount'] ?? 0}', Icons.tv, Colors.indigo),
                    _kpi(t('categories'), '${data['categoriesCount'] ?? 0}', Icons.category, Colors.teal),
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.newspaper, color: Colors.blue),
                          ),
                          title: Text(
                            (item['title'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            (item['created_at'] ?? '').toString().split('T').first,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          trailing: ((item['is_hidden'] ?? false) == true)
                              ? Chip(
                                  label: Text(t('hidden'), style: const TextStyle(fontSize: 10, color: Colors.white)),
                                  backgroundColor: Colors.grey,
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.flash_on, color: Colors.red),
                          ),
                          title: Text(
                            (item['title'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            t('from_to')
                                .replaceFirst('{start}', (item['start_time'] ?? '').toString().substring(11, 16))
                                .replaceFirst('{end}', (item['end_time'] ?? '').toString().substring(11, 16)),
                            style: TextStyle(color: Colors.grey[500]),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('dashboard_overview'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t('welcome_message') ?? 'Welcome back to the dashboard', // Add generic fallback
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.push('/dashboard/main-news/add'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(t('add_news')),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E3A8A),
                side: const BorderSide(color: Color(0xFF1E3A8A)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildRecentList(String title, List<dynamic> items, Widget Function(dynamic) itemBuilder) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          if (items.isEmpty)
             Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text('No items yet', style: TextStyle(color: Colors.grey[400]))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (_, index) => itemBuilder(items[index]),
            ),
        ],
      ),
    );
  }
}
