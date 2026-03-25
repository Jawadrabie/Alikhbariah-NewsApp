import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/utils/relative_time_formatter.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../home/data/models/news_model.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../../home/presentation/widgets/news_card.dart';
import '../../data/services/bookmark_service.dart';

class NewsDetailsScreen extends StatefulWidget {
  final NewsModel news;

  const NewsDetailsScreen({super.key, required this.news});

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
  List<NewsModel> _relatedNews = const [];
  String _currentLanguageCode = 'ar';

  @override
  void initState() {
    super.initState();
    _loadBookmarkState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = Localizations.localeOf(context).languageCode.toLowerCase();
    if (_currentLanguageCode == languageCode && !_relatedLoading) {
      return;
    }

    _currentLanguageCode = languageCode;
    _loadRelatedNews();
  }

  Future<void> _loadBookmarkState() async {
    final bookmarked = await _bookmarkService.isBookmarked(widget.news.id);
    if (!mounted) return;
    setState(() {
      _isBookmarked = bookmarked;
      _bookmarkLoading = false;
    });
  }

  Future<void> _loadRelatedNews() async {
    try {
      final byCategory = await _homeRepository.getLatestNews(
        languageCode: _currentLanguageCode,
        limit: 10,
        categoryId: widget.news.categoryId,
      );

      final filteredByCategory = byCategory
          .where((item) => item.id != widget.news.id)
          .take(5)
          .toList();

      if (filteredByCategory.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _relatedNews = filteredByCategory;
          _relatedLoading = false;
        });
        return;
      }

      final fallbackLatest = await _homeRepository.getLatestNews(
        languageCode: _currentLanguageCode,
        limit: 10,
      );
      final filteredFallback = fallbackLatest
          .where((item) => item.id != widget.news.id)
          .take(5)
          .toList();

      if (!mounted) return;
      setState(() {
        _relatedNews = filteredFallback;
        _relatedLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _relatedNews = const [];
        _relatedLoading = false;
      });
    }
  }

  void _increaseFontSize() {
    setState(() {
      if (_fontSize < 30.0) _fontSize += 2.0;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 12.0) _fontSize -= 2.0;
    });
  }

  Future<void> _shareArticle() async {
    final String title = widget.news.title;
    // Mock URL as we don't have deep linking yet
    final String url = 'https://newsapp.example.com/news/${widget.news.id}';
    await SharePlus.instance.share(
      ShareParams(
        text: '$title\n\n$url',
      ),
    );
  }

  Future<void> _toggleBookmark() async {
    final l10n = context.l10n;
    final nowBookmarked = await _bookmarkService.toggleBookmark(widget.news);
    if (!mounted) return;

    setState(() {
      _isBookmarked = nowBookmarked;
      _bookmarkLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowBookmarked ? l10n.newsSavedLocally : l10n.newsRemovedFromSaved,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = widget.news.title;
    final content = widget.news.content;
    final imageUrl = widget.news.imageUrl;
    // Category is just an ID in NewsModel, so we'll just show "News" or skip it for now
    // In a real app we would join with Category table or fetch category name.
    final category = l10n.categoryNews;
    final publishedAt = widget.news.createdAt;
    final localeName = Localizations.localeOf(context).toString();
    final formattedDate = DateFormat('yyyy-MM-dd – HH:mm', localeName).format(publishedAt);
    final relativeDate = formatRelativeTime(context, publishedAt);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(l10n.articleDetails, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.text_increase),
                onPressed: _increaseFontSize,
                tooltip: l10n.increaseFontSize,
              ),
              IconButton(
                icon: const Icon(Icons.text_decrease),
                onPressed: _decreaseFontSize,
                tooltip: l10n.decreaseFontSize,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareArticle,
                tooltip: l10n.share,
              ),
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                ),
                onPressed: _bookmarkLoading ? null : _toggleBookmark,
                tooltip: _isBookmarked ? l10n.removeFromSaved : l10n.saveNews,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'news_image_${widget.news.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerLoading(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 0,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      )
                    else
                      Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.article, size: 70, color: Colors.grey),
                      ),
                    // Gradient overlay for better text readability and seamless transition
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Colors.black87,
                          ],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.3,
                          ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          relativeDate,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const Divider(height: 48, thickness: 1),
                    // Content with HTML rendering
                    Directionality(
                      textDirection: Directionality.of(context),
                      child: HtmlWidget(
                        content,
                        textStyle: TextStyle(
                          fontSize: _fontSize,
                          height: 1.8,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                        ),
                        onTapUrl: (url) async {
                          if (!await launchUrl(Uri.parse(url))) {
                            throw Exception(l10n.openLinkFailed);
                          }
                          return true;
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (!_relatedLoading && _relatedNews.isNotEmpty) ...[
                      Text(
                        l10n.relatedNews,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _relatedNews.length,
                        itemBuilder: (context, index) {
                          return NewsCard(news: _relatedNews[index]);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
