import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      // Handle error
    }
  }

  String _getCategoryName(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id).name;
    } catch (e) {
      return 'N/A';
    }
  }

  String _getLocationName(String id) {
    try {
      return _locations.firstWhere((l) => l.id == id).name;
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main News'),
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
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          }

          final newsList = snapshot.data![0] as List<News>;
          _categories = snapshot.data![1] as List<Category>;
          _locations = snapshot.data![2] as List<Location>;

          if (newsList.isEmpty) {
            return const Center(child: Text('No news found.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Published')),
                DataColumn(label: Text('Featured')),
                DataColumn(label: Text('Views')),
                DataColumn(label: Text('Actions')),
              ],
              rows: newsList.map((news) {
                return DataRow(cells: [
                  DataCell(Text(news.title)),
                  DataCell(Text(_getCategoryName(news.categoryId))),
                  DataCell(Text(_getLocationName(news.locationId))),
                  DataCell(Text(news.createdAt.toString())),
                  DataCell(Text(news.isHidden ? 'No' : 'Yes')),
                  DataCell(Text(news.isFeatured ? 'Yes' : 'No')),
                  DataCell(Text(news.viewCount.toString())),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await context.push('/dashboard/main-news/edit/${news.id}', extra: news);
                          _loadData();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteNews(news.id),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
