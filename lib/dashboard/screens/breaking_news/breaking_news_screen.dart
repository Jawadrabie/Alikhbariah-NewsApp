import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/breaking_news.dart';
import 'package:newsappjs/dashboard/services/breaking_news_service.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

enum _BreakingStatusFilter { all, coming, active, ended }

enum _BreakingNotificationFilter { all, enabledOnly, disabledOnly }

enum _BreakingViewsFilter {
  all,
  under50,
  from50To99,
  from100To199,
  from200Plus,
}

enum _BreakingSortOption {
  latestStart,
  oldestStart,
  mostViewed,
  leastViewed,
  endingSoon,
}

class BreakingNewsScreen extends StatefulWidget {
  const BreakingNewsScreen({super.key});

  @override
  State<BreakingNewsScreen> createState() => _BreakingNewsScreenState();
}

class _BreakingNewsScreenState extends State<BreakingNewsScreen> {
  final BreakingNewsService _service = BreakingNewsService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _tableScrollController = ScrollController();
  late Future<List<BreakingNews>> _future;

  String _searchQuery = '';
  DateTime? _selectedDate;
  _BreakingStatusFilter _statusFilter = _BreakingStatusFilter.all;
  _BreakingNotificationFilter _notificationFilter =
      _BreakingNotificationFilter.all;
  _BreakingViewsFilter _viewsFilter = _BreakingViewsFilter.all;
  _BreakingSortOption _sortOption = _BreakingSortOption.latestStart;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _reload();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    _tableScrollController.dispose();
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

  void _reload() {
    setState(() {
      _future = _service.getBreakingNews();
    });
  }

  _BreakingStatusFilter _statusOf(BreakingNews item) {
    final now = DateTime.now();
    if (now.isBefore(item.startTime)) {
      return _BreakingStatusFilter.coming;
    }
    if (now.isAfter(item.endTime)) {
      return _BreakingStatusFilter.ended;
    }
    return _BreakingStatusFilter.active;
  }

  String _statusLabel(_BreakingStatusFilter status) {
    switch (status) {
      case _BreakingStatusFilter.all:
        return DashboardI18n.t(context, 'breaking_status_all');
      case _BreakingStatusFilter.coming:
        return DashboardI18n.t(context, 'breaking_status_coming');
      case _BreakingStatusFilter.active:
        return DashboardI18n.t(context, 'breaking_status_active');
      case _BreakingStatusFilter.ended:
        return DashboardI18n.t(context, 'breaking_status_ended');
    }
  }

  String _formatDateTime(DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(value);
    final time = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value));
    return '$date $time';
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  int _activeFilterCount() {
    var count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_selectedDate != null) count++;
    if (_statusFilter != _BreakingStatusFilter.all) count++;
    if (_notificationFilter != _BreakingNotificationFilter.all) count++;
    if (_viewsFilter != _BreakingViewsFilter.all) count++;
    if (_sortOption != _BreakingSortOption.latestStart) count++;
    return count;
  }

  String _resultsSummaryText(int shown, int total) {
    return DashboardI18n.t(context, 'breaking_results_summary')
        .replaceAll('{shown}', shown.toString())
        .replaceAll('{total}', total.toString());
  }

  String _activeFiltersText(int count) {
    return DashboardI18n.t(
      context,
      'active_filters',
    ).replaceAll('{count}', count.toString());
  }

  String _notificationFilterLabel(_BreakingNotificationFilter filter) {
    switch (filter) {
      case _BreakingNotificationFilter.all:
        return DashboardI18n.t(context, 'notification_all');
      case _BreakingNotificationFilter.enabledOnly:
        return DashboardI18n.t(context, 'notification_enabled_only');
      case _BreakingNotificationFilter.disabledOnly:
        return DashboardI18n.t(context, 'notification_disabled_only');
    }
  }

  String _viewsFilterLabel(_BreakingViewsFilter filter) {
    switch (filter) {
      case _BreakingViewsFilter.all:
        return DashboardI18n.t(context, 'views_all');
      case _BreakingViewsFilter.under50:
        return DashboardI18n.t(context, 'views_under_50');
      case _BreakingViewsFilter.from50To99:
        return DashboardI18n.t(context, 'views_50_99');
      case _BreakingViewsFilter.from100To199:
        return DashboardI18n.t(context, 'views_100_199');
      case _BreakingViewsFilter.from200Plus:
        return DashboardI18n.t(context, 'views_200_plus');
    }
  }

  String _sortLabel(_BreakingSortOption option) {
    switch (option) {
      case _BreakingSortOption.latestStart:
        return DashboardI18n.t(context, 'sort_latest_start');
      case _BreakingSortOption.oldestStart:
        return DashboardI18n.t(context, 'sort_oldest_start');
      case _BreakingSortOption.mostViewed:
        return DashboardI18n.t(context, 'sort_most_viewed');
      case _BreakingSortOption.leastViewed:
        return DashboardI18n.t(context, 'sort_least_viewed');
      case _BreakingSortOption.endingSoon:
        return DashboardI18n.t(context, 'sort_ending_soon');
    }
  }

  bool _matchesViewsFilter(BreakingNews item) {
    switch (_viewsFilter) {
      case _BreakingViewsFilter.all:
        return true;
      case _BreakingViewsFilter.under50:
        return item.viewCount < 50;
      case _BreakingViewsFilter.from50To99:
        return item.viewCount >= 50 && item.viewCount <= 99;
      case _BreakingViewsFilter.from100To199:
        return item.viewCount >= 100 && item.viewCount <= 199;
      case _BreakingViewsFilter.from200Plus:
        return item.viewCount >= 200;
    }
  }

  List<BreakingNews> _applyFilters(List<BreakingNews> items) {
    final normalizedQuery = _searchQuery.toLowerCase();
    final filtered =
        items.where((item) {
          final status = _statusOf(item);

          if (_statusFilter != _BreakingStatusFilter.all &&
              status != _statusFilter) {
            return false;
          }

          if (_notificationFilter == _BreakingNotificationFilter.enabledOnly &&
              !item.sendNotification) {
            return false;
          }

          if (_notificationFilter == _BreakingNotificationFilter.disabledOnly &&
              item.sendNotification) {
            return false;
          }

          if (_selectedDate != null &&
              !_isSameDate(item.startTime.toLocal(), _selectedDate!)) {
            return false;
          }

          if (!_matchesViewsFilter(item)) {
            return false;
          }

          if (normalizedQuery.isEmpty) {
            return true;
          }

          final searchable =
              <String>[
                item.title,
                item.titleEn,
                item.content,
                item.contentEn,
              ].join(' ').toLowerCase();

          return searchable.contains(normalizedQuery);
        }).toList();

    filtered.sort((first, second) {
      switch (_sortOption) {
        case _BreakingSortOption.latestStart:
          return second.startTime.compareTo(first.startTime);
        case _BreakingSortOption.oldestStart:
          return first.startTime.compareTo(second.startTime);
        case _BreakingSortOption.mostViewed:
          final byViews = second.viewCount.compareTo(first.viewCount);
          return byViews != 0
              ? byViews
              : second.startTime.compareTo(first.startTime);
        case _BreakingSortOption.leastViewed:
          final byViews = first.viewCount.compareTo(second.viewCount);
          return byViews != 0
              ? byViews
              : second.startTime.compareTo(first.startTime);
        case _BreakingSortOption.endingSoon:
          return first.endTime.compareTo(second.endTime);
      }
    });

    return filtered;
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
      _selectedDate = null;
      _statusFilter = _BreakingStatusFilter.all;
      _notificationFilter = _BreakingNotificationFilter.all;
      _viewsFilter = _BreakingViewsFilter.all;
      _sortOption = _BreakingSortOption.latestStart;
    });
  }

  Future<void> _delete(String id) async {
    try {
      await _service.deleteBreakingNews(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error')}: $e',
      );
    }
  }

  Widget _buildStatBadge({required IconData icon, required String label}) {
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

  TextStyle _filterLabelStyle() {
    final scheme = Theme.of(context).colorScheme;
    return Theme.of(context).textTheme.labelMedium!.copyWith(
      fontWeight: FontWeight.w700,
      color: scheme.onSurfaceVariant,
    );
  }

  Widget _buildLabeledControl({
    required String label,
    required Widget child,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _filterLabelStyle()),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildControlSurface({required Widget child, bool isActive = false}) {
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

  Widget _buildSearchControl() {
    final scheme = Theme.of(context).colorScheme;
    return _buildLabeledControl(
      label: DashboardI18n.t(context, 'search_breaking_news'),
      width: 320,
      child: _buildControlSurface(
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
                  hintText: DashboardI18n.t(
                    context,
                    'search_breaking_news_hint',
                  ),
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                tooltip: DashboardI18n.t(context, 'clear_filters'),
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

  Widget _buildActionControl({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required double width,
    bool isActive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return _buildLabeledControl(
      label: label,
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: _buildControlSurface(
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
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: SizedBox(
        width: 64,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: _buildControlSurface(
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
      ),
    );
  }

  Widget _buildStatusBadge(BreakingNews item) {
    final scheme = Theme.of(context).colorScheme;
    final status = _statusOf(item);
    late final Color backgroundColor;
    late final Color foregroundColor;

    switch (status) {
      case _BreakingStatusFilter.coming:
        backgroundColor = scheme.secondaryContainer;
        foregroundColor = scheme.onSecondaryContainer;
      case _BreakingStatusFilter.active:
        backgroundColor = scheme.tertiaryContainer;
        foregroundColor = scheme.onTertiaryContainer;
      case _BreakingStatusFilter.ended:
        backgroundColor = scheme.errorContainer;
        foregroundColor = scheme.onErrorContainer;
      case _BreakingStatusFilter.all:
        backgroundColor = scheme.surfaceContainerHighest;
        foregroundColor = scheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActiveFiltersRow() {
    final chips = <Widget>[];

    if (_searchQuery.isNotEmpty) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.search_rounded, size: 18),
          label: Text('${DashboardI18n.t(context, 'search')}: $_searchQuery'),
          onDeleted: () => _searchController.clear(),
        ),
      );
    }

    if (_statusFilter != _BreakingStatusFilter.all) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.bolt_outlined, size: 18),
          label: Text(
            '${DashboardI18n.t(context, 'status')}: '
            '${_statusLabel(_statusFilter)}',
          ),
          onDeleted: () {
            setState(() {
              _statusFilter = _BreakingStatusFilter.all;
            });
          },
        ),
      );
    }

    if (_notificationFilter != _BreakingNotificationFilter.all) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.notifications_active_outlined, size: 18),
          label: Text(
            '${DashboardI18n.t(context, 'notify')}: '
            '${_notificationFilterLabel(_notificationFilter)}',
          ),
          onDeleted: () {
            setState(() {
              _notificationFilter = _BreakingNotificationFilter.all;
            });
          },
        ),
      );
    }

    if (_viewsFilter != _BreakingViewsFilter.all) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.visibility_outlined, size: 18),
          label: Text(
            '${DashboardI18n.t(context, 'views')}: '
            '${_viewsFilterLabel(_viewsFilter)}',
          ),
          onDeleted: () {
            setState(() {
              _viewsFilter = _BreakingViewsFilter.all;
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
            '${DashboardI18n.t(context, 'date')}: '
            '${MaterialLocalizations.of(context).formatShortDate(_selectedDate!)}',
          ),
          onDeleted: () {
            setState(() {
              _selectedDate = null;
            });
          },
        ),
      );
    }

    if (_sortOption != _BreakingSortOption.latestStart) {
      chips.add(
        InputChip(
          avatar: const Icon(Icons.swap_vert_rounded, size: 18),
          label: Text(
            '${DashboardI18n.t(context, 'sort_by')}: '
            '${_sortLabel(_sortOption)}',
          ),
          onDeleted: () {
            setState(() {
              _sortOption = _BreakingSortOption.latestStart;
            });
          },
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _buildFiltersPanel({
    required int shownCount,
    required int totalCount,
  }) {
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
                icon: Icons.feed_outlined,
                label: _resultsSummaryText(shownCount, totalCount),
              ),
              _buildStatBadge(
                icon: Icons.tune_rounded,
                label: _activeFiltersText(activeFilterCount),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _buildSearchControl(),
              _buildFilterDropdown<_BreakingStatusFilter>(
                label: DashboardI18n.t(context, 'status'),
                value: _statusFilter,
                icon: Icons.bolt_outlined,
                items:
                    _BreakingStatusFilter.values
                        .map(
                          (option) => DropdownMenuItem<_BreakingStatusFilter>(
                            value: option,
                            child: Text(_statusLabel(option)),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _statusFilter = value;
                  });
                },
              ),
              _buildFilterDropdown<_BreakingNotificationFilter>(
                label: DashboardI18n.t(context, 'notify'),
                value: _notificationFilter,
                icon: Icons.notifications_active_outlined,
                items:
                    _BreakingNotificationFilter.values
                        .map(
                          (option) =>
                              DropdownMenuItem<_BreakingNotificationFilter>(
                                value: option,
                                child: Text(_notificationFilterLabel(option)),
                              ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _notificationFilter = value;
                  });
                },
              ),
              _buildFilterDropdown<_BreakingViewsFilter>(
                label: DashboardI18n.t(context, 'views'),
                value: _viewsFilter,
                icon: Icons.visibility_outlined,
                items:
                    _BreakingViewsFilter.values
                        .map(
                          (option) => DropdownMenuItem<_BreakingViewsFilter>(
                            value: option,
                            child: Text(_viewsFilterLabel(option)),
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
              _buildFilterDropdown<_BreakingSortOption>(
                label: DashboardI18n.t(context, 'sort_by'),
                value: _sortOption,
                icon: Icons.swap_vert_rounded,
                items:
                    _BreakingSortOption.values
                        .map(
                          (option) => DropdownMenuItem<_BreakingSortOption>(
                            value: option,
                            child: Text(_sortLabel(option)),
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
              _buildActionControl(
                label: DashboardI18n.t(context, 'date'),
                value:
                    _selectedDate == null
                        ? DashboardI18n.t(context, 'pick_date')
                        : MaterialLocalizations.of(
                          context,
                        ).formatShortDate(_selectedDate!),
                icon: Icons.calendar_today_outlined,
                onTap: _pickDate,
                width: 220,
                isActive: _selectedDate != null,
              ),
              _buildIconActionControl(
                tooltip: DashboardI18n.t(context, 'clear_filters'),
                icon: Icons.restart_alt_rounded,
                onTap: _clearFilters,
                isActive: activeFilterCount > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<BreakingNews> items) {
    final scheme = Theme.of(context).colorScheme;
    return Scrollbar(
      controller: _tableScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _tableScrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          columns: [
            DataColumn(label: Text(DashboardI18n.t(context, 'title'))),
            DataColumn(label: Text(DashboardI18n.t(context, 'start'))),
            DataColumn(label: Text(DashboardI18n.t(context, 'end'))),
            DataColumn(label: Text(DashboardI18n.t(context, 'status'))),
            DataColumn(label: Text(DashboardI18n.t(context, 'notify'))),
            DataColumn(label: Text(DashboardI18n.t(context, 'views'))),
            DataColumn(label: Text(DashboardI18n.t(context, 'actions'))),
          ],
          rows:
              items.map((item) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 320,
                        child: Text(
                          item.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(Text(_formatDateTime(item.startTime))),
                    DataCell(Text(_formatDateTime(item.endTime))),
                    DataCell(_buildStatusBadge(item)),
                    DataCell(
                      Text(
                        item.sendNotification
                            ? DashboardI18n.t(context, 'yes')
                            : DashboardI18n.t(context, 'no'),
                      ),
                    ),
                    DataCell(Text(item.viewCount.toString())),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: DashboardI18n.t(context, 'edit'),
                            icon: Icon(Icons.edit, color: scheme.primary),
                            onPressed: () async {
                              await context.push(
                                '/dashboard/breaking-news/edit/${item.id}',
                                extra: item,
                              );
                              if (!mounted) return;
                              _reload();
                            },
                          ),
                          IconButton(
                            tooltip: DashboardI18n.t(context, 'delete'),
                            icon: Icon(Icons.delete, color: scheme.error),
                            onPressed: () => _delete(item.id),
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
    return Scaffold(
      body: FutureBuilder<List<BreakingNews>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${DashboardI18n.t(context, 'error')}: ${snapshot.error}',
              ),
            );
          }

          final items = snapshot.data ?? [];
          final filteredItems = _applyFilters(items);

          return DashboardSectionView(
            title: DashboardI18n.t(context, 'breaking_news'),
            actions: [
              FilledButton.icon(
                onPressed: () async {
                  await context.push('/dashboard/breaking-news/add');
                  if (!mounted) return;
                  _reload();
                },
                icon: const Icon(Icons.add_alert),
                label: Text(DashboardI18n.t(context, 'add_breaking_news')),
              ),
            ],
            child:
                items.isEmpty
                    ? DashboardEmptyState(
                      icon: Icons.new_releases_outlined,
                      title: DashboardI18n.t(context, 'no_breaking_news_found'),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFiltersPanel(
                          shownCount: filteredItems.length,
                          totalCount: items.length,
                        ),
                        if (_activeFilterCount() > 0) ...[
                          const SizedBox(height: 14),
                          _buildActiveFiltersRow(),
                        ],
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child:
                              filteredItems.isEmpty
                                  ? DashboardEmptyState(
                                    key: const ValueKey('empty-filtered'),
                                    icon: Icons.filter_alt_off_outlined,
                                    title: DashboardI18n.t(
                                      context,
                                      'no_breaking_news_match_filters',
                                    ),
                                  )
                                  : _buildTable(filteredItems),
                        ),
                      ],
                    ),
          );
        },
      ),
    );
  }
}
