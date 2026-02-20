import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/user_report.dart';
import 'package:newsappjs/dashboard/services/user_reports_service.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text(t('user_reports'))),
      body: FutureBuilder<List<UserReport>>(
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
            return Center(child: Text(t('no_user_reports')));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(t('report_name'))),
                DataColumn(label: Text(t('report_phone'))),
                DataColumn(label: Text(t('report_text'))),
                DataColumn(label: Text(t('attachment'))),
                DataColumn(label: Text(t('date'))),
                DataColumn(label: Text(t('report_status'))),
                DataColumn(label: Text(t('actions'))),
              ],
              rows: items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.name ?? t('na'))),
                        DataCell(Text(item.phone ?? t('na'))),
                        DataCell(SizedBox(width: 360, child: Text(item.message))),
                        DataCell(Text(item.attachmentUrl ?? t('na'))),
                        DataCell(Text(item.createdAt.toString())),
                        DataCell(
                          Chip(
                            label: Text(item.isReviewed ? t('read') : t('unread')),
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
                                ),
                                tooltip: item.isReviewed
                                    ? t('mark_as_unread')
                                    : t('mark_as_read'),
                                onPressed: () => _toggleReviewed(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
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
          );
        },
      ),
    );
  }
}
