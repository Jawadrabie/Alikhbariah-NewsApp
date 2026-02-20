import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../data/repositories/media_repository.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final MediaRepository _repository = MediaRepository();

  Future<void> _openLive(String url) async {
    final l10n = context.l10n;
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedOpenLiveLink)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.liveStream)),
      body: FutureBuilder(
        future: _repository.getActiveLiveStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(l10n.failedLoadLiveStream(snapshot.error.toString())));
          }

          final stream = snapshot.data;
          if (stream == null || stream.youtubeUrl.isEmpty) {
            return Center(child: Text(l10n.noLiveNow));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stream.broadcastTitle?.isNotEmpty == true
                              ? stream.broadcastTitle!
                              : l10n.defaultLiveTitle,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stream.fallbackMessage?.isNotEmpty == true
                              ? stream.fallbackMessage!
                              : l10n.defaultLiveMessage,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _openLive(stream.youtubeUrl),
                  icon: const Icon(Icons.live_tv_rounded),
                  label: Text(l10n.openLiveStream),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
