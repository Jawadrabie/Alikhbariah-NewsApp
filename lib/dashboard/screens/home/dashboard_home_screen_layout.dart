// ignore_for_file: invalid_use_of_protected_member

part of 'dashboard_home_screen.dart';

extension _DashboardHomeScreenView on _DashboardHomeScreenState {
  Widget _buildScreen(BuildContext context) {
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
              padding: const EdgeInsets.all(24),
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
}
