import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../data/models/video_item_model.dart';
import '../../data/repositories/media_repository.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key, this.programId, this.programName});

  final int? programId;
  final String? programName;

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final MediaRepository _repository = MediaRepository();
  late Future<List<VideoItemModel>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _repository.getVideos(programId: widget.programId);
  }

  String _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    }

    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'] ?? '';
    }

    final segments = uri.pathSegments;
    final index = segments.indexOf('embed');
    if (index != -1 && segments.length > index + 1) {
      return segments[index + 1];
    }

    return '';
  }

  String _thumbnailOf(VideoItemModel item) {
    if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
      return item.thumbnailUrl!;
    }

    final id = _extractYoutubeId(item.youtubeUrl);
    if (id.isEmpty) {
      return '';
    }

    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  Future<void> _openVideo(String url) async {
    final l10n = context.l10n;
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedOpenVideoLink)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeName = Localizations.localeOf(context).toString();
    final title = widget.programName == null
        ? l10n.videos
        : l10n.programEpisodes(widget.programName!);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<VideoItemModel>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(l10n.failedLoadVideos(snapshot.error.toString())));
          }

          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return Center(child: Text(l10n.noVideosNow));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final thumb = _thumbnailOf(item);
                final date = intl
                  .DateFormat('yyyy-MM-dd – HH:mm', localeName)
                  .format(item.publishedAt ?? item.createdAt);

              return Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: InkWell(
                  onTap: () => _openVideo(item.youtubeUrl),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 110,
                            height: 72,
                            color: const Color(0xFFE5EBEF),
                            child: thumb.isEmpty
                                ? const Icon(Icons.play_circle_fill_rounded)
                                : Image.network(thumb, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                date,
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
