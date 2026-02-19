import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../home/data/models/news_model.dart';
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
  bool _isBookmarked = false;
  bool _bookmarkLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarkState();
  }

  Future<void> _loadBookmarkState() async {
    final bookmarked = await _bookmarkService.isBookmarked(widget.news.id);
    if (!mounted) return;
    setState(() {
      _isBookmarked = bookmarked;
      _bookmarkLoading = false;
    });
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
    final nowBookmarked = await _bookmarkService.toggleBookmark(widget.news);
    if (!mounted) return;

    setState(() {
      _isBookmarked = nowBookmarked;
      _bookmarkLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowBookmarked ? 'تم حفظ الخبر محلياً' : 'تمت إزالة الخبر من المحفوظات',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.news.title;
    final content = widget.news.content;
    final imageUrl = widget.news.imageUrl;
    // Category is just an ID in NewsModel, so we'll just show "News" or skip it for now
    // In a real app we would join with Category table or fetch category name.
    const category = 'News'; 
    final publishedAt = widget.news.createdAt;
    
    final formattedDate = DateFormat('yyyy-MM-dd – HH:mm').format(publishedAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: _increaseFontSize,
            tooltip: 'Increase Font Size',
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: _decreaseFontSize,
            tooltip: 'Decrease Font Size',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareArticle,
            tooltip: 'Share',
          ),
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
            onPressed: _bookmarkLoading ? null : _toggleBookmark,
            tooltip: _isBookmarked ? 'إزالة من المحفوظات' : 'حفظ الخبر',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerLoading(
                  width: double.infinity,
                  height: 250,
                  borderRadius: 0,
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50), // Dark Blue
                        ),
                    textAlign: TextAlign.right, // Assuming Arabic titles
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0392B), // Dark Red
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          category,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // Content with HTML rendering
                  Directionality(
                    textDirection: Directionality.of(context),
                    child: HtmlWidget(
                      content,
                      textStyle: TextStyle(
                        fontSize: _fontSize,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      onTapUrl: (url) async {
                        if (!await launchUrl(Uri.parse(url))) {
                          throw Exception('Could not launch $url');
                        }
                        return true;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
