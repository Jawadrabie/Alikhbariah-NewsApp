import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/live_stream.dart';
import 'package:newsappjs/dashboard/services/live_stream_service.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final _service = LiveStreamService();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _fallbackController = TextEditingController();
  bool _isActive = false;
  bool _loading = true;
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
      _fallbackController.text = data?.fallbackMessage ?? '';
      _isActive = data?.isActive ?? false;
      _loading = false;
    });
  }

  Future<void> _save() async {
    String t(String key) => DashboardI18n.t(context, key);
    final stream = LiveStream(
      id: _id ?? '',
      youtubeUrl: _urlController.text.trim(),
      isActive: _isActive,
      broadcastTitle: _titleController.text.trim(),
      fallbackMessage: _fallbackController.text.trim(),
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
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _fallbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t('live_stream')),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.save),
        label: Text(_id == null || _id!.isEmpty ? t('save') : t('save_changes')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: t('broadcast_title')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(labelText: t('youtube_url')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fallbackController,
                maxLines: 2,
                decoration: InputDecoration(labelText: t('fallback_message')),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t('active')),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
