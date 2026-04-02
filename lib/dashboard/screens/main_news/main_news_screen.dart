import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/models/location.dart';
import 'package:newsappjs/dashboard/models/news.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/services/location_service.dart';
import 'package:newsappjs/dashboard/services/news_service.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

enum _NewsSortOption { newest, oldest, mostViewed, leastViewed, featuredFirst }

enum _FeaturedFilter { all, featuredOnly, nonFeaturedOnly }

enum _ViewsFilter { all, under50, from50To99, from100To199, from200Plus }

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
  final ScrollController _newsTableScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _featuredOverrides = {};
  final Set<String> _updatingFeaturedIds = {};

  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _selectedLocationId;
  DateTime? _selectedDate;
  _NewsSortOption _sortOption = _NewsSortOption.newest;
  _FeaturedFilter _featuredFilter = _FeaturedFilter.all;
  _ViewsFilter _viewsFilter = _ViewsFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _newsTableScrollController.dispose();
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    final nextQuery = _searchController.text.trim();
    if (nextQuery == _searchQuery) {
      return;
    }
    setState(() {
      _searchQuery = nextQuery;
    });
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
      setState(() {
        _featuredOverrides.remove(id);
        _updatingFeaturedIds.remove(id);
      });
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2, 12, 31),
      locale: Localizations.localeOf(context),
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategoryId = null;
      _selectedLocationId = null;
      _selectedDate = null;
      _sortOption = _NewsSortOption.newest;
      _featuredFilter = _FeaturedFilter.all;
      _viewsFilter = _ViewsFilter.all;
    });
  }

  bool _effectiveFeatured(News news) =>
      _featuredOverrides[news.id] ?? news.isFeatured;

  int _activeFilterCount() {
    var count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_selectedCategoryId != null) count++;
    if (_selectedLocationId != null) count++;
    if (_selectedDate != null) count++;
    if (_featuredFilter != _FeaturedFilter.all) count++;
    if (_viewsFilter != _ViewsFilter.all) count++;
    if (_sortOption != _NewsSortOption.newest) count++;
    return count;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  int _compareByNewest(News first, News second) {
    return second.createdAt.compareTo(first.createdAt);
  }

  int _compareByOldest(News first, News second) {
    return first.createdAt.compareTo(second.createdAt);
  }

  List<News> _applyNewsFilters({
    required List<News> newsList,
    required Map<String, String> categoryNameById,
    required Map<String, String> locationNameById,
  }) {
    final normalizedQuery = _searchQuery.toLowerCase();

    final filtered =
        newsList.where((news) {
          final featured = _effectiveFeatured(news);
          final locationId =
              (news.locationId == null || news.locationId!.isEmpty)
                  ? null
                  : news.locationId;
          final createdAtLocal = news.createdAt.toLocal();

          if (_selectedCategoryId != null &&
              news.categoryId != _selectedCategoryId) {
            return false;
          }

          if (_selectedLocationId != null &&
              locationId != _selectedLocationId) {
            return false;
          }

          if (_selectedDate != null &&
              !_isSameDate(createdAtLocal, _selectedDate!)) {
            return false;
          }

          if (_featuredFilter == _FeaturedFilter.featuredOnly && !featured) {
            return false;
          }

          if (_featuredFilter == _FeaturedFilter.nonFeaturedOnly && featured) {
            return false;
          }

          if (!_matchesViewsFilter(news)) {
            return false;
          }

          if (normalizedQuery.isEmpty) {
            return true;
          }

          final searchableText =
              <String>[
                news.title,
                news.titleEn,
                categoryNameById[news.categoryId] ?? '',
                if (locationId != null) locationNameById[locationId] ?? '',
              ].join(' ').toLowerCase();

          return searchableText.contains(normalizedQuery);
        }).toList();

    filtered.sort((first, second) {
      switch (_sortOption) {
        case _NewsSortOption.newest:
          return _compareByNewest(first, second);
        case _NewsSortOption.oldest:
          return _compareByOldest(first, second);
        case _NewsSortOption.mostViewed:
          final byViews = second.viewCount.compareTo(first.viewCount);
          return byViews != 0 ? byViews : _compareByNewest(first, second);
        case _NewsSortOption.leastViewed:
          final byViews = first.viewCount.compareTo(second.viewCount);
          return byViews != 0 ? byViews : _compareByNewest(first, second);
        case _NewsSortOption.featuredFirst:
          final firstFeatured = _effectiveFeatured(first);
          final secondFeatured = _effectiveFeatured(second);
          if (firstFeatured != secondFeatured) {
            return firstFeatured ? -1 : 1;
          }
          return _compareByNewest(first, second);
      }
    });

    return filtered;
  }

  String _formatDate(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('yyyy/MM/dd', locale).format(dateTime.toLocal());
  }

  String _resultsSummaryText(BuildContext context, int shown, int total) {
    return DashboardI18n.t(context, 'results_summary')
        .replaceAll('{shown}', shown.toString())
        .replaceAll('{total}', total.toString());
  }

  String _activeFiltersText(BuildContext context, int count) {
    return DashboardI18n.t(
      context,
      'active_filters',
    ).replaceAll('{count}', count.toString());
  }

  String _sortLabel(BuildContext context, _NewsSortOption option) {
    switch (option) {
      case _NewsSortOption.newest:
        return DashboardI18n.t(context, 'sort_newest');
      case _NewsSortOption.oldest:
        return DashboardI18n.t(context, 'sort_oldest');
      case _NewsSortOption.mostViewed:
        return DashboardI18n.t(context, 'sort_most_viewed');
      case _NewsSortOption.leastViewed:
        return DashboardI18n.t(context, 'sort_least_viewed');
      case _NewsSortOption.featuredFirst:
        return DashboardI18n.t(context, 'sort_featured_first');
    }
  }

  String _viewsFilterLabel(BuildContext context, _ViewsFilter option) {
    switch (option) {
      case _ViewsFilter.all:
        return DashboardI18n.t(context, 'views_all');
      case _ViewsFilter.under50:
        return DashboardI18n.t(context, 'views_under_50');
      case _ViewsFilter.from50To99:
        return DashboardI18n.t(context, 'views_50_99');
      case _ViewsFilter.from100To199:
        return DashboardI18n.t(context, 'views_100_199');
      case _ViewsFilter.from200Plus:
        return DashboardI18n.t(context, 'views_200_plus');
    }
  }

  bool _matchesViewsFilter(News news) {
    switch (_viewsFilter) {
      case _ViewsFilter.all:
        return true;
      case _ViewsFilter.under50:
        return news.viewCount < 50;
      case _ViewsFilter.from50To99:
        return news.viewCount >= 50 && news.viewCount <= 99;
      case _ViewsFilter.from100To199:
        return news.viewCount >= 100 && news.viewCount <= 199;
      case _ViewsFilter.from200Plus:
        return news.viewCount >= 200;
    }
  }

  List<News> _normalizeNewsList(dynamic source) {
    if (source is! List) {
      return const <News>[];
    }

    return source
        .map((item) {
          if (item is News) {
            return item;
          }
          if (item is Map<String, dynamic>) {
            return News.fromJson(item);
          }
          if (item is Map) {
            return News.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        })
        .whereType<News>()
        .toList();
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required BuildContext context,
    required String label,
    required T value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return CustomDropdownField<T>(
      value: value,
      width: 220,
      isDense: true,
      labelText: label,
      prefixIcon: Icon(icon),
      items: items,
      onChanged: onChanged,
      enableSearch: items.length > 6,
    );
  }

  TextStyle _filterLabelStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.labelMedium!.copyWith(
      fontWeight: FontWeight.w700,
      color: scheme.onSurfaceVariant,
    );
  }

  Widget _buildLabeledFilterControl({
    required BuildContext context,
    required String label,
    required Widget child,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _filterLabelStyle(context)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildFilterControlSurface({
    required BuildContext context,
    required Widget child,
    bool isActive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.surface,
            scheme.surfaceContainerLowest.withValues(alpha: 0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isActive
                  ? scheme.primary.withValues(alpha: 0.45)
                  : scheme.outlineVariant.withValues(alpha: 0.90),
          width: 1.15,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSearchControl(BuildContext context) {
    final t = DashboardI18n.t;
    final scheme = Theme.of(context).colorScheme;
    return _buildLabeledFilterControl(
      context: context,
      width: 320,
      label: t(context, 'search_news'),
      child: _buildFilterControlSurface(
        context: context,
        isActive: _searchQuery.isNotEmpty,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 18,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration.collapsed(
                  hintText: t(context, 'search_news_hint'),
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                tooltip: t(context, 'clear_filters'),
                onPressed: () => _searchController.clear(),
                visualDensity: VisualDensity.compact,
                splashRadius: 18,
                icon: Icon(
                  Icons.close_rounded,
                  color: scheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionFilterControl({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required double width,
    bool isActive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return _buildLabeledFilterControl(
      context: context,
      width: width,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: _buildFilterControlSurface(
            context: context,
            isActive: isActive,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: scheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconActionControl({
    required BuildContext context,
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 64,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: _buildFilterControlSurface(
            context: context,
            isActive: isActive,
            child: Center(
              child: Tooltip(
                message: tooltip,
                child: Icon(
                  icon,
                  color: isActive ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedFilterChips(BuildContext context) {
    final t = DashboardI18n.t;
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(t(context, 'featured_all')),
          selected: _featuredFilter == _FeaturedFilter.all,
          onSelected: (_) {
            setState(() {
              _featuredFilter = _FeaturedFilter.all;
            });
          },
        ),
        ChoiceChip(
          label: Text(t(context, 'featured_only')),
          selected: _featuredFilter == _FeaturedFilter.featuredOnly,
          selectedColor: scheme.tertiaryContainer,
          onSelected: (_) {
            setState(() {
              _featuredFilter = _FeaturedFilter.featuredOnly;
            });
          },
        ),
        ChoiceChip(
          label: Text(t(context, 'non_featured_only')),
          selected: _featuredFilter == _FeaturedFilter.nonFeaturedOnly,
          onSelected: (_) {
            setState(() {
              _featuredFilter = _FeaturedFilter.nonFeaturedOnly;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActiveFiltersRow(
    BuildContext context, {
    required Map<String, String> categoryNameById,
    required Map<String, String> locationNameById,
  }) {
    final t = DashboardI18n.t;
    final chips = <Widget>[];

    if (_searchQuery.isNotEmpty) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.search_rounded, size: 18),
          label: Text('${t(context, 'search')}: $_searchQuery'),
          onDeleted: () {
            _searchController.clear();
          },
        ),
      );
    }

    if (_selectedCategoryId != null) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.category_outlined, size: 18),
          label: Text(
            '${t(context, 'category')}: '
            '${categoryNameById[_selectedCategoryId] ?? t(context, 'na')}',
          ),
          onDeleted: () {
            setState(() {
              _selectedCategoryId = null;
            });
          },
        ),
      );
    }

    if (_selectedLocationId != null) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.location_on_outlined, size: 18),
          label: Text(
            '${t(context, 'location')}: '
            '${locationNameById[_selectedLocationId] ?? t(context, 'na')}',
          ),
          onDeleted: () {
            setState(() {
              _selectedLocationId = null;
            });
          },
        ),
      );
    }

    if (_selectedDate != null) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(
            '${t(context, 'date')}: ${_formatDate(context, _selectedDate!)}',
          ),
          onDeleted: () {
            setState(() {
              _selectedDate = null;
            });
          },
        ),
      );
    }

    if (_featuredFilter != _FeaturedFilter.all) {
      final label =
          _featuredFilter == _FeaturedFilter.featuredOnly
              ? t(context, 'featured_only')
              : t(context, 'non_featured_only');
      chips.add(
        InputChip(
          avatar: const Icon(Icons.star_outline_rounded, size: 18),
          label: Text('${t(context, 'featured')}: $label'),
          onDeleted: () {
            setState(() {
              _featuredFilter = _FeaturedFilter.all;
            });
          },
        ),
      );
    }

    if (_viewsFilter != _ViewsFilter.all) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.visibility_outlined, size: 18),
          label: Text(
            '${t(context, 'views')}: ${_viewsFilterLabel(context, _viewsFilter)}',
          ),
          onDeleted: () {
            setState(() {
              _viewsFilter = _ViewsFilter.all;
            });
          },
        ),
      );
    }

    if (_sortOption != _NewsSortOption.newest) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.swap_vert_rounded, size: 18),
          label: Text(
            '${t(context, 'sort_by')}: ${_sortLabel(context, _sortOption)}',
          ),
          onDeleted: () {
            setState(() {
              _sortOption = _NewsSortOption.newest;
            });
          },
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _buildFiltersPanel(
    BuildContext context, {
    required List<Category> categories,
    required List<Location> locations,
    required int filteredCount,
    required int totalCount,
  }) {
    final t = DashboardI18n.t;
    final scheme = Theme.of(context).colorScheme;
    final activeFilterCount = _activeFilterCount();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            scheme.surfaceContainerLowest,
            scheme.surfaceContainerHigh.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatBadge(
                context,
                icon: Icons.feed_outlined,
                label: _resultsSummaryText(context, filteredCount, totalCount),
              ),
              _buildStatBadge(
                context,
                icon: Icons.tune_rounded,
                label: _activeFiltersText(context, activeFilterCount),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _buildSearchControl(context),
              _buildFilterDropdown<String?>(
                context: context,
                label: t(context, 'category'),
                value: _selectedCategoryId,
                icon: Icons.category_outlined,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(t(context, 'all')),
                  ),
                  ...categories.map(
                    (category) => DropdownMenuItem<String?>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              _buildFilterDropdown<String?>(
                context: context,
                label: t(context, 'location'),
                value: _selectedLocationId,
                icon: Icons.location_on_outlined,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(t(context, 'all')),
                  ),
                  ...locations.map(
                    (location) => DropdownMenuItem<String?>(
                      value: location.id,
                      child: Text(location.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLocationId = value;
                  });
                },
              ),
              _buildFilterDropdown<_ViewsFilter>(
                context: context,
                label: t(context, 'views'),
                value: _viewsFilter,
                icon: Icons.visibility_outlined,
                items:
                    _ViewsFilter.values
                        .map(
                          (option) => DropdownMenuItem<_ViewsFilter>(
                            value: option,
                            child: Text(_viewsFilterLabel(context, option)),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _viewsFilter = value;
                  });
                },
              ),
              _buildFilterDropdown<_NewsSortOption>(
                context: context,
                label: t(context, 'sort_by'),
                value: _sortOption,
                icon: Icons.swap_vert_rounded,
                items:
                    _NewsSortOption.values
                        .map(
                          (option) => DropdownMenuItem<_NewsSortOption>(
                            value: option,
                            child: Text(_sortLabel(context, option)),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _sortOption = value;
                  });
                },
              ),
              _buildActionFilterControl(
                context: context,
                label: t(context, 'date'),
                value:
                    _selectedDate == null
                        ? t(context, 'pick_date')
                        : _formatDate(context, _selectedDate!),
                icon: Icons.calendar_today_outlined,
                onTap: _pickDate,
                width: 220,
                isActive: _selectedDate != null,
              ),
              _buildIconActionControl(
                context: context,
                tooltip: t(context, 'clear_filters'),
                icon: Icons.restart_alt_rounded,
                onTap: _clearFilters,
                isActive: activeFilterCount > 0,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeaturedFilterChips(context),
        ],
      ),
    );
  }

  Widget _buildNewsTable({
    required BuildContext context,
    required List<News> newsList,
    required Map<String, String> categoryNameById,
    required Map<String, String> locationNameById,
  }) {
    final t = DashboardI18n.t;
    final scheme = Theme.of(context).colorScheme;

    return Scrollbar(
      controller: _newsTableScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _newsTableScrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          columns: [
            DataColumn(label: Text(t(context, 'title'))),
            DataColumn(label: Text(t(context, 'category'))),
            DataColumn(label: Text(t(context, 'location'))),
            DataColumn(label: Text(t(context, 'date'))),
            DataColumn(label: Text(t(context, 'published'))),
            DataColumn(label: Text(t(context, 'featured'))),
            DataColumn(label: Text(t(context, 'views'))),
            DataColumn(label: Text(t(context, 'actions'))),
          ],
          rows:
              newsList.map((news) {
                final displayedFeatured = _effectiveFeatured(news);
                final isUpdatingFeatured = _updatingFeaturedIds.contains(
                  news.id,
                );
                final locationId =
                    (news.locationId == null || news.locationId!.isEmpty)
                        ? null
                        : news.locationId;

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 240,
                        child: Text(
                          news.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        categoryNameById[news.categoryId] ?? t(context, 'na'),
                      ),
                    ),
                    DataCell(
                      Text(
                        locationId == null
                            ? t(context, 'na')
                            : (locationNameById[locationId] ??
                                t(context, 'na')),
                      ),
                    ),
                    DataCell(Text(_formatDate(context, news.createdAt))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              !news.isHidden
                                  ? scheme.secondaryContainer
                                  : scheme.errorContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          !news.isHidden ? t(context, 'yes') : t(context, 'no'),
                          style: TextStyle(
                            color:
                                !news.isHidden
                                    ? scheme.onSecondaryContainer
                                    : scheme.onErrorContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        onPressed:
                            isUpdatingFeatured
                                ? null
                                : () => _toggleFeatured(news),
                        icon: Icon(
                          displayedFeatured ? Icons.star : Icons.star_border,
                          color:
                              displayedFeatured
                                  ? scheme.tertiary
                                  : scheme.outlineVariant,
                          size: 20,
                        ),
                        tooltip: t(context, 'featured'),
                      ),
                    ),
                    DataCell(Text(news.viewCount.toString())),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 20,
                              color: scheme.primary,
                            ),
                            onPressed: () async {
                              await context.push(
                                '/dashboard/main-news/edit/${news.id}',
                                extra: news,
                              );
                              _loadData();
                            },
                            tooltip: t(context, 'edit'),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: 20,
                              color: scheme.error,
                            ),
                            onPressed: () => _deleteNews(news.id),
                            tooltip: t(context, 'delete'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);

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

          final newsList = _normalizeNewsList(snapshot.data?[0]);
          final categories =
              snapshot.data?[1] as List<Category>? ?? const <Category>[];
          final locations =
              snapshot.data?[2] as List<Location>? ?? const <Location>[];
          final categoryNameById = {
            for (final category in categories) category.id: category.name,
          };
          final locationNameById = {
            for (final location in locations) location.id: location.name,
          };
          final filteredNews = _applyNewsFilters(
            newsList: newsList,
            categoryNameById: categoryNameById,
            locationNameById: locationNameById,
          );

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
            child:
                newsList.isEmpty
                    ? DashboardEmptyState(
                      icon: Icons.article_outlined,
                      title: t('no_news_found'),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFiltersPanel(
                          context,
                          categories: categories,
                          locations: locations,
                          filteredCount: filteredNews.length,
                          totalCount: newsList.length,
                        ),
                        if (_activeFilterCount() > 0) ...[
                          const SizedBox(height: 14),
                          _buildActiveFiltersRow(
                            context,
                            categoryNameById: categoryNameById,
                            locationNameById: locationNameById,
                          ),
                        ],
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child:
                              filteredNews.isEmpty
                                  ? DashboardEmptyState(
                                    key: const ValueKey('filtered-empty'),
                                    icon: Icons.filter_alt_off_outlined,
                                    title: t('no_news_match_filters'),
                                  )
                                  : KeyedSubtree(
                                    key: const ValueKey('filtered-table'),
                                    child: _buildNewsTable(
                                      context: context,
                                      newsList: filteredNews,
                                      categoryNameById: categoryNameById,
                                      locationNameById: locationNameById,
                                    ),
                                  ),
                        ),
                      ],
                    ),
          );
        },
      ),
    );
  }
}
