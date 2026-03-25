import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/live_stream.dart';
import 'package:newsappjs/dashboard/services/live_stream_service.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/dashboard_button_content.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final LiveStreamService _service = LiveStreamService();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _titleEnController = TextEditingController();
  final TextEditingController _fallbackController = TextEditingController();
  final TextEditingController _fallbackEnController = TextEditingController();

  bool _isActive = false;
  bool _loading = true;
  bool _isSaving = false;
  String? _id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getLiveStream();
    if (!mounted) return;

    setState(() {
      _id = data?.id;
      _urlController.text = data?.youtubeUrl ?? '';
      _titleController.text = data?.broadcastTitle ?? '';
      _titleEnController.text = data?.broadcastTitleEn ?? '';
      _fallbackController.text = data?.fallbackMessage ?? '';
      _fallbackEnController.text = data?.fallbackMessageEn ?? '';
      _isActive = data?.isActive ?? false;
      _loading = false;
    });
  }

  Future<void> _save() async {
    String t(String key) => DashboardI18n.t(context, key);
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final stream = LiveStream(
      id: _id ?? '',
      youtubeUrl: _urlController.text.trim(),
      isActive: _isActive,
      broadcastTitle: _titleController.text.trim(),
      broadcastTitleEn: _titleEnController.text.trim(),
      fallbackMessage: _fallbackController.text.trim(),
      fallbackMessageEn: _fallbackEnController.text.trim(),
    );

    try {
      await _service.upsertLiveStream(stream);
      await _load();
      if (!mounted) return;
      await DashboardDialogs.showSuccess(context, t('save_successful'));
    } catch (e) {
      if (!mounted) return;
      await DashboardDialogs.showError(
        context,
        '${t('error_saving_live_stream')}: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _titleEnController.dispose();
    _fallbackController.dispose();
    _fallbackEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DashboardSectionView(
      title: t('live_stream'),
      actions: [
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: const Icon(Icons.save),
          label: DashboardLoadingButtonChild(
            isLoading: _isSaving,
            label: _id == null || _id!.isEmpty ? t('save') : t('save_changes'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.live_tv, color: scheme.error, size: 28),
                const SizedBox(width: 12),
                Text(
                  t('live_stream'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _titleController,
              labelText: t('broadcast_title_ar'),
              prefixIcon: const Icon(Icons.title),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _titleEnController,
              labelText: t('broadcast_title_en'),
              prefixIcon: const Icon(Icons.title),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _urlController,
              labelText: t('youtube_url'),
              prefixIcon: const Icon(Icons.link),
              hintText: 'https://www.youtube.com/watch?v=...',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _fallbackController,
              minLines: 3,
              maxLines: null,
              labelText: t('fallback_message_ar'),
              prefixIcon: const Icon(Icons.message_outlined),
              alignLabelWithHint: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _fallbackEnController,
              minLines: 3,
              maxLines: null,
              labelText: t('fallback_message_en'),
              prefixIcon: const Icon(Icons.message_outlined),
              alignLabelWithHint: true,
            ),
            const SizedBox(height: 24),
            CustomSwitchTile(
              title: t('active'),
              subtitle:
                  _isActive
                      ? 'البث المباشر مفعل حالياً ويظهر للمستخدمين'
                      : 'البث المباشر متوقف حالياً',
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ],
        ),
      ),
    );
  }
}
