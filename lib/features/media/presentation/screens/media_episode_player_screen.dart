import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../data/models/video_item_model.dart';
import '../controllers/in_app_video_controller.dart';

part 'media_episode_player_screen_logic.dart';
part 'media_episode_player_screen_view.dart';

class MediaEpisodePlayerScreen extends StatefulWidget {
  const MediaEpisodePlayerScreen({
    super.key,
    required this.episodes,
    required this.initialIndex,
    required this.listTitle,
  });

  final List<VideoItemModel> episodes;
  final int initialIndex;
  final String listTitle;

  @override
  State<MediaEpisodePlayerScreen> createState() =>
      _MediaEpisodePlayerScreenState();
}

class _MediaEpisodePlayerScreenState extends State<MediaEpisodePlayerScreen> {
  late int _currentIndex;
  late final WebViewController _webViewController;
  String? _playbackError;
  bool _isExpandedPlayer = false;
  bool _isInlinePlayerMinimized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.episodes.length - 1);
    _webViewController = _buildWebViewController();
    _loadCurrentEpisode();
  }

  VideoItemModel get _currentEpisode => widget.episodes[_currentIndex];

  @override
  void dispose() {
    _restorePortraitMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildScreen(context);
}
