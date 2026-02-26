import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/models/location.dart';
import 'package:newsappjs/dashboard/models/news.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/services/location_service.dart';
import 'package:newsappjs/dashboard/services/news_service.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class MainNewsScreen extends StatefulWidget {
  const MainNewsScreen({super.key});

  @override
  State<MainNewsScreen> createState() => _MainNewsScreenState();
}

class _MainNewsScreenState extends State<MainNewsScreen> {
  late Future<List<dynamic>> _dataFuture;
  final NewsService _newsService = NewsService();
  final CategoryService _categoryService = CategoryService();
  final LocationService _locationService = LocationService();
  final Map<String, bool> _featuredOverrides = {};
  final Set<String> _updatingFeaturedIds = {};

  List<Category> _categories = [];
  List<Location> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = Future.wait([
        _newsService.getNews(),
        _categoryService.getCategories(type: 'news'),
        _locationService.getLocations(),
      ]);
    });
  }

  void _deleteNews(String id) async {
    try {
      await _newsService.deleteNews(id);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_news')}: $e',
      );
    }
  }

  Future<void> _toggleFeatured(News news) async {
    final t = DashboardI18n.t;
    if (_updatingFeaturedIds.contains(news.id)) {
      return;
    }

    final currentValue = _featuredOverrides[news.id] ?? news.isFeatured;
    final nextValue = !currentValue;

    setState(() {
      _featuredOverrides[news.id] = nextValue;
      _updatingFeaturedIds.add(news.id);
    });

    try {
      await _newsService.updateFeaturedStatus(
        id: news.id,
        isFeatured: nextValue,
      );
      if (!mounted) return;
      setState(() {
        _updatingFeaturedIds.remove(news.id);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _featuredOverrides[news.id] = currentValue;
        _updatingFeaturedIds.remove(news.id);
      });
      await DashboardDialogs.showError(
        context,
        '${t(context, 'error_updating_news')}: $e',
      );
    }
  }

  String _getCategoryName(String id) {
    final t = DashboardI18n.t;
    try {
      return _categories.firstWhere((c) => c.id == id).name;
    } catch (e) {
      return t(context, 'na');
    }
  }

  String _getLocationName(String? id) {
    final t = DashboardI18n.t;
    if (id == null || id.isEmpty) {
      return t(context, 'na');
    }
    try {
      return _locations.firstWhere((l) => l.id == id).name;
    } catch (e) {
      return t(context, 'na');
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${t('error')}: ${snapshot.error}'));
          }

          final newsList = snapshot.data?[0] as List<News>? ?? [];
          if (snapshot.hasData) {
            _categories = snapshot.data![1] as List<Category>;
            _locations = snapshot.data![2] as List<Location>;
          }

          return DashboardSectionView(
            title: t('main_news'),
            actions: [
              FilledButton.icon(
                onPressed: () async {
                  await context.push('/dashboard/main-news/add');
                  _loadData();
                },
                icon: const Icon(Icons.add),
                label: Text(t('add_news')),
              ),
            ],
            child: newsList.isEmpty
                ? DashboardEmptyState(
                    icon: Icons.article_outlined,
                    title: t('no_news_found'),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      columns: [
                        DataColumn(label: Text(t('title'))),
                        DataColumn(label: Text(t('category'))),
                        DataColumn(label: Text(t('location'))),
                        DataColumn(label: Text(t('date'))),
                        DataColumn(label: Text(t('published'))),
                        DataColumn(label: Text(t('featured'))),
                        DataColumn(label: Text(t('views'))),
                        DataColumn(label: Text(t('actions'))),
                      ],
                      rows: newsList.map((news) {
                        final displayedFeatured = _featuredOverrides[news.id] ?? news.isFeatured;
                        final isUpdatingFeatured = _updatingFeaturedIds.contains(news.id);
                        return DataRow(
                          cells: [
                            DataCell(SizedBox(
                              width: 200,
                              child: Text(news.title, overflow: TextOverflow.ellipsis),
                            )),
                            DataCell(Text(_getCategoryName(news.categoryId))),
                            DataCell(Text(_getLocationName(news.locationId))),
                            DataCell(Text(news.createdAt.toString().split(' ')[0])),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: !news.isHidden ? scheme.secondaryContainer : scheme.errorContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                !news.isHidden ? t('yes') : t('no'),
                                style: TextStyle(
                                  color: !news.isHidden
                                      ? scheme.onSecondaryContainer
                                      : scheme.onErrorContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )),
                            DataCell(
                              IconButton(
                                onPressed: isUpdatingFeatured ? null : () => _toggleFeatured(news),
                                icon: Icon(
                                  displayedFeatured ? Icons.star : Icons.star_border,
                                  color: displayedFeatured ? scheme.tertiary : scheme.outlineVariant,
                                  size: 20,
                                ),
                                tooltip: t('featured'),
                              ),
                            ),
                            DataCell(Text(news.viewCount.toString())),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, size: 20, color: scheme.primary),
                                  onPressed: () async {
                                    await context.push('/dashboard/main-news/edit/${news.id}', extra: news);
                                    _loadData();
                                  },
                                  tooltip: t('edit'),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, size: 20, color: scheme.error),
                                  onPressed: () => _deleteNews(news.id),
                                  tooltip: t('delete'),
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
