import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart' as intl;
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/utils/image_prefetch_guard.dart';
import '../../../../core/utils/relative_time_formatter.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/config/app_env.dart';
import '../../../home/data/models/news_model.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../data/services/bookmark_service.dart';

part 'news_details_screen_logic.dart';
part 'news_details_screen_related.dart';
part 'news_details_screen_view.dart';

class NewsDetailsScreen extends StatefulWidget {
  const NewsDetailsScreen({super.key, required this.news});

  final NewsModel news;

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  double _fontSize = 18.0;
  final BookmarkService _bookmarkService = BookmarkService();
  final HomeRepository _homeRepository = HomeRepository();
  bool _isBookmarked = false;
  bool _bookmarkLoading = true;
  bool _relatedLoading = true;
  bool _locationLoading = false;
  List<NewsModel> _relatedNews = const [];
  String _currentLanguageCode = 'ar';
  String? _resolvedLocationName;

  @override
  void initState() {
    super.initState();
    _resolvedLocationName = widget.news.locationName;
    _warmImageUrls([widget.news.imageUrl]);
    _loadBookmarkState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageCode =
        Localizations.localeOf(context).languageCode.toLowerCase();
    final languageChanged = _currentLanguageCode != languageCode;
    _currentLanguageCode = languageCode;

    if (languageChanged || _relatedLoading) {
      _loadRelatedNews(useCache: true);
    }

    final shouldResolveLocation =
        widget.news.locationId != null &&
        (languageChanged ||
            _resolvedLocationName == null ||
            _resolvedLocationName!.trim().isEmpty);
    if (shouldResolveLocation) {
      _resolveLocationName();
    }
  }

  String? get _governorateName {
    final resolved = _resolvedLocationName?.trim();
    if (resolved != null && resolved.isNotEmpty) return resolved;

    final fromWidget = widget.news.locationName?.trim();
    if (fromWidget != null && fromWidget.isNotEmpty) return fromWidget;

    return null;
  }

  @override
  Widget build(BuildContext context) => _buildScaffold(context);
}
