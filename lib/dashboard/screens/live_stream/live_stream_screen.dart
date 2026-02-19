import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/models/live_stream.dart';
import 'package:newsappjs/dashboard/services/live_stream_service.dart';
import 'package:uuid/uuid.dart';

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
    final stream = LiveStream(
      id: _id ?? const Uuid().v4(),
      youtubeUrl: _urlController.text.trim(),
      isActive: _isActive,
      broadcastTitle: _titleController.text.trim(),
      fallbackMessage: _fallbackController.text.trim(),
    );
    await _service.upsertLiveStream(stream);
    await _load();
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
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
                decoration: const InputDecoration(labelText: 'Broadcast Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'YouTube URL'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fallbackController,
                maxLines: 2,
                decoration:
                    const InputDecoration(labelText: 'Fallback Message'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Broadcast Active'),
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
