import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/localization/l10n_extensions.dart';
import '../../data/models/video_category_model.dart';
import '../../data/models/video_item_model.dart';
import '../../data/repositories/media_repository.dart';
import 'media_episode_player_screen.dart';

part 'videos_screen_logic.dart';
part 'videos_screen_view.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({
    super.key,
    this.programId,
    this.programName,
    this.categoryId,
    this.categoryName,
    this.showLatestVideos = false,
    this.latestVideosTitle,
  });

  final int? programId;
  final String? programName;
  final int? categoryId;
  final String? categoryName;
  final bool showLatestVideos;
  final String? latestVideosTitle;

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final MediaRepository _repository = MediaRepository();
  late Future<List<VideoItemModel>> _videosFuture;
  late Future<List<VideoCategoryModel>> _categoriesFuture;
  String _currentLanguageCode = 'ar';

  bool get _isEpisodesMode =>
      widget.programId != null ||
      widget.categoryId != null ||
      widget.showLatestVideos;

  @override
  void initState() {
    super.initState();
    _videosFuture = Future.value(const <VideoItemModel>[]);
    _categoriesFuture = Future.value(const <VideoCategoryModel>[]);
    _initializeFutures();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextLanguage =
        Localizations.localeOf(context).languageCode.toLowerCase();
    if (_currentLanguageCode == nextLanguage) {
      return;
    }
    _currentLanguageCode = nextLanguage;
    _initializeFutures();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEpisodesMode) {
      return _buildEpisodesView(context);
    }
    return _buildCategoriesView(context);
  }
}
