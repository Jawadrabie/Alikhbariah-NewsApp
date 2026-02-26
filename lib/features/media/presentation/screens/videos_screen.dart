import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/localization/l10n_extensions.dart';
import '../controllers/in_app_video_controller.dart';
import '../../data/models/program_model.dart';
import '../../data/models/video_category_model.dart';
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
  late Future<_VideosHomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    if (widget.programId != null) {
      _videosFuture = _repository.getVideos(programId: widget.programId);
    } else {
      _homeFuture = _loadHomeData();
    }
  }

  Future<_VideosHomeData> _loadHomeData() async {
    final categories = await _repository.getVideoCategories();
    final programs = await _repository.getPrograms();

    final videosByCategoryEntries = await Future.wait(
      categories.map((category) async {
        final videos = await _repository.getVideos(categoryId: category.id);
        return MapEntry(category.id, videos);
      }),
    );

    final videosByCategory = <int, List<VideoItemModel>>{};
    for (final entry in videosByCategoryEntries) {
      videosByCategory[entry.key] = entry.value;
    }

    return _VideosHomeData(
      categories: categories,
      programs: programs,
      videosByCategory: videosByCategory,
    );
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

  Future<void> _openVideo(VideoItemModel item) async {
    final l10n = context.l10n;
    final didStart = InAppVideoController.instance.play(
      youtubeUrl: item.youtubeUrl,
      title: item.title,
    );

    if (!didStart) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedOpenVideoLink)),
      );
      return;
    }

  }

  @override
  Widget build(BuildContext context) {
    if (widget.programId != null) {
      return _buildProgramEpisodesView(context);
    }
    return _buildVideosHomeView(context);
  }

  Widget _buildProgramEpisodesView(BuildContext context) {
    final l10n = context.l10n;
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
            itemBuilder: (context, index) => _buildVideoListTile(context, items[index]),
          );
        },
      ),
    );
  }

  Widget _buildVideosHomeView(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.videos)),
      body: FutureBuilder<_VideosHomeData>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(l10n.failedLoadVideos(snapshot.error.toString())));
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(child: Text(l10n.noVideosNow));
          }

          final sections = <Widget>[];

          if (data.programs.isNotEmpty) {
            sections
              ..add(_buildSectionHeader(context, l10n.programs))
              ..add(
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.programs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final program = data.programs[index];
                      return _buildProgramCard(context, program);
                    },
                  ),
                ),
              )
              ..add(const SizedBox(height: 8));
          }

          for (final category in data.categories) {
            final videos = data.videosByCategory[category.id] ?? const <VideoItemModel>[];
            if (videos.isEmpty) continue;

            sections
              ..add(_buildSectionHeader(context, category.name))
              ..add(
                SizedBox(
                  height: 188,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: videos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _buildVideoCard(videos[index]),
                  ),
                ),
              )
              ..add(const SizedBox(height: 8));
          }

          if (sections.isEmpty) {
            return Center(child: Text(l10n.noVideosNow));
          }

          return ListView(children: sections);
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, ProgramModel program) {
    return SizedBox(
      width: 190,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideosScreen(
                  programId: program.id,
                  programName: program.name,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: const Color(0xFFE5EBEF),
                      width: double.infinity,
                      child: program.imageUrl == null || program.imageUrl!.isEmpty
                          ? const Icon(Icons.video_collection_rounded)
                          : Image.network(
                              program.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.video_collection_rounded),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  program.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(VideoItemModel item) {
    final thumb = _thumbnailOf(item);
    return SizedBox(
      width: 230,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openVideo(item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    thumb.isEmpty
                        ? Container(
                            color: const Color(0xFFE5EBEF),
                            child: const Icon(
                              Icons.play_circle_fill_rounded,
                              size: 34,
                            ),
                          )
                        : Image.network(
                            thumb,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFE5EBEF),
                              child: const Icon(
                                Icons.play_circle_fill_rounded,
                                size: 34,
                              ),
                            ),
                          ),
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoListTile(BuildContext context, VideoItemModel item) {
    final localeName = Localizations.localeOf(context).toString();
    final thumb = _thumbnailOf(item);
    final date = intl
        .DateFormat('yyyy-MM-dd – HH:mm', localeName)
        .format(item.publishedAt ?? item.createdAt);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: InkWell(
        onTap: () => _openVideo(item),
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
              const Icon(Icons.play_circle_fill_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideosHomeData {
  final List<VideoCategoryModel> categories;
  final List<ProgramModel> programs;
  final Map<int, List<VideoItemModel>> videosByCategory;

  const _VideosHomeData({
    required this.categories,
    required this.programs,
    required this.videosByCategory,
  });
}
