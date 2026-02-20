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
        _categoryService.getCategories(),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(t('main_news')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/dashboard/main-news/add');
              _loadData();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/dashboard/main-news/add');
          _loadData();
        },
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(t('add_news')),
      ),
      backgroundColor: Colors.transparent, // Use dashboard background
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.article, size: 32, color: Color(0xFF1E3A8A)), // Match corporate blue
                const SizedBox(width: 12),
                Text(
                  t('main_news'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                color: Colors.white,
                child: FutureBuilder<List<dynamic>>(
                  future: _dataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('${t('error')}: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || (snapshot.data?[0] as List?)?.isEmpty == true) { // Safer check
                      return Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(t('no_news_found'), style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        ],
                      ));
                    }
            
                    final newsList = snapshot.data![0] as List<News>;
                    // Remove duplicate assignment if possible or just use existing logic
                    // _categories = snapshot.data![1] as List<Category>; // Assuming safe
                    // _locations = snapshot.data![2] as List<Location>; // Assuming safe
            
                    return SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(0),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                          dataRowColor: MaterialStateProperty.resolveWith((states) {
                             // striping logic or hover could go here
                             return Colors.white;
                          }),
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          dataTextStyle: const TextStyle(color: Color(0xFF334155)),
                          columnSpacing: 24,
                          horizontalMargin: 24,
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
                            return DataRow(
                              cells: [
                                DataCell(SizedBox(
                                  width: 200,
                                  child: Text(news.title, overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Text(_getCategoryName(news.categoryId))),
                                DataCell(Text(_getLocationName(news.locationId))),
                                DataCell(Text(news.createdAt.toString().split(' ')[0])), // Shorten date
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: !news.isHidden ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    !news.isHidden ? t('yes') : t('no'),
                                    style: TextStyle(
                                      color: !news.isHidden ? Colors.green[700] : Colors.red[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )),
                                DataCell(Icon(
                                  news.isFeatured ? Icons.star : Icons.star_border,
                                  color: news.isFeatured ? Colors.amber : Colors.grey[300],
                                  size: 20,
                                )),
                                DataCell(Text(news.viewCount.toString())),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                      onPressed: () async {
                                        await context.push('/dashboard/main-news/edit/${news.id}', extra: news);
                                        _loadData();
                                      },
                                      tooltip: t('edit'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
