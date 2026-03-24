import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/breaking_news.dart';
import 'package:newsappjs/dashboard/services/breaking_news_service.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';

class EditBreakingNewsScreen extends StatefulWidget {
  final BreakingNews? breakingNews;
  const EditBreakingNewsScreen({super.key, this.breakingNews});

  @override
  State<EditBreakingNewsScreen> createState() => _EditBreakingNewsScreenState();
}

class _EditBreakingNewsScreenState extends State<EditBreakingNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _titleEnController;
  late final TextEditingController _contentController;
  late final TextEditingController _contentEnController;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  bool _sendNotification = true;
  bool _isLoading = false;

  final BreakingNewsService _breakingNewsService = BreakingNewsService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.breakingNews?.title);
    _titleEnController = TextEditingController(text: widget.breakingNews?.titleEn);
    _contentController =
        TextEditingController(text: widget.breakingNews?.content);
    _contentEnController = TextEditingController(text: widget.breakingNews?.contentEn);
    if (widget.breakingNews != null) {
      _startTime = widget.breakingNews!.startTime;
      _endTime = widget.breakingNews!.endTime;
      _sendNotification = widget.breakingNews!.sendNotification;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleEnController.dispose();
    _contentController.dispose();
    _contentEnController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatFullDate(value);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
    );
    return '$date - $time';
  }

  Future<void> _selectDateTime({required bool isStart}) async {
    final currentValue = isStart ? _startTime : _endTime;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentValue,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate == null) return;

    if (!mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentValue),
    );
    if (selectedTime == null) return;
    if (!mounted) return;

    setState(() {
      final updated = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      if (isStart) {
        _startTime = updated;
        if (!_endTime.isAfter(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      } else {
        _endTime = updated;
      }
    });
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_endTime.isAfter(_startTime)) {
        DashboardDialogs.showError(
          context,
          DashboardI18n.t(context, 'end_time_must_be_after_start'),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final breakingNews = BreakingNews(
        id: widget.breakingNews?.id ?? '',
        title: _titleController.text.trim(),
        titleEn: _titleEnController.text.trim(),
        content: _contentController.text.trim(),
        contentEn: _contentEnController.text.trim(),
        createdAt: widget.breakingNews?.createdAt ?? DateTime.now(),
        startTime: _startTime,
        endTime: _endTime,
        sendNotification: _sendNotification,
      );

      try {
        if (widget.breakingNews == null) {
          await _breakingNewsService.createBreakingNews(breakingNews);
        } else {
          await _breakingNewsService.updateBreakingNews(breakingNews);
        }
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          await DashboardDialogs.showError(
            context,
            '${DashboardI18n.t(context, 'error_saving_breaking_news')}: $e',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breakingNews == null
            ? t('add_breaking_news')
            : t('edit_breaking_news')),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.save),
              label: Text(t('save')),
              style: TextButton.styleFrom(foregroundColor: scheme.primary),
              onPressed: _saveForm,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  controller: _titleController,
                  labelText: t('title_ar'),
                  validator: (value) =>
                      value!.isEmpty ? t('please_enter_title') : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _titleEnController,
                  labelText: t('title_en'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? t('please_enter_title_en') : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _contentController,
                  labelText: t('content_ar'),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? t('please_enter_content') : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _contentEnController,
                  labelText: t('content_en'),
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? t('please_enter_content_en') : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${t('start_time')}: ${_formatDateTime(_startTime)}',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _selectDateTime(isStart: true),
                      child: Text(t('select')),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${t('end_time')}: ${_formatDateTime(_endTime)}',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () => _selectDateTime(isStart: false),
                      child: Text(t('select')),
                    )
                  ],
                ),
                CustomSwitchTile(
                  title: t('send_notification'),
                  value: _sendNotification,
                  onChanged: (value) =>
                      setState(() => _sendNotification = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveForm,
                    icon: const Icon(Icons.save),
                    label: Text(widget.breakingNews == null ? t('create_breaking_news') : t('save_changes')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
