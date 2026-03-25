import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/user_report.dart';
import 'package:newsappjs/dashboard/services/user_reports_service.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class UserReportsScreen extends StatefulWidget {
  const UserReportsScreen({super.key});

  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen> {
  final UserReportsService _service = UserReportsService();
  late Future<List<UserReport>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.getReports();
    });
  }

  Future<void> _toggleReviewed(UserReport report) async {
    try {
      await _service.updateReviewStatus(report.id, !report.isReviewed);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_updating_report_status')}: $e',
      );
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _service.deleteReport(id);
      _reload();
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${DashboardI18n.t(context, 'error_deleting_report')}: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    return DashboardSectionView(
      title: t('user_reports'),
      child: FutureBuilder<List<UserReport>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${t('error')}: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return DashboardEmptyState(
              title: t('no_user_reports'),
              icon: Icons.report_off_outlined,
            );
          }

          return DashboardSurfaceCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      t('report_name'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      t('report_phone'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      t('report_text'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      t('attachment'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      t('date'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      t('report_status'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      t('actions'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows:
                    items
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(Text(item.name ?? t('na'))),
                              DataCell(Text(item.phone ?? t('na'))),
                              DataCell(
                                SizedBox(width: 360, child: Text(item.message)),
                              ),
                              DataCell(Text(item.attachmentUrl ?? t('na'))),
                              DataCell(
                                Text(item.createdAt.toString().split('.')[0]),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        item.isReviewed
                                            ? scheme.secondaryContainer
                                            : scheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          item.isReviewed
                                              ? scheme.secondary
                                              : scheme.tertiary,
                                    ),
                                  ),
                                  child: Text(
                                    item.isReviewed ? t('read') : t('unread'),
                                    style: TextStyle(
                                      color:
                                          item.isReviewed
                                              ? scheme.onSecondaryContainer
                                              : scheme.onTertiaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        item.isReviewed
                                            ? Icons.mark_email_unread
                                            : Icons.mark_email_read,
                                        color:
                                            item.isReviewed
                                                ? scheme.tertiary
                                                : scheme.secondary,
                                      ),
                                      tooltip:
                                          item.isReviewed
                                              ? t('mark_as_unread')
                                              : t('mark_as_read'),
                                      onPressed: () => _toggleReviewed(item),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: scheme.error,
                                      ),
                                      onPressed: () => _delete(item.id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
