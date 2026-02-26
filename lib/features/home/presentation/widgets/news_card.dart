import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/utils/relative_time_formatter.dart';
import '../../data/models/news_model.dart';
import '../../../../features/news/presentation/screens/news_details_screen.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.news});

  final NewsModel news;

  String _contentPreview(String htmlContent) {
    final plain = htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (plain.isEmpty) return '';
    if (plain.length <= 110) return plain;
    return '${plain.substring(0, 110)}...';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textDirection = Directionality.of(context);
    final relativeTime = formatRelativeTime(context, news.createdAt);
    final preview = _contentPreview(news.content);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailsScreen(news: news),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      textAlign: TextAlign.start,
                      textDirection: textDirection,
                    ),
                    const SizedBox(height: 6),
                    if (preview.isNotEmpty) ...[
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF4B5563), height: 1.4),
                        textAlign: TextAlign.start,
                        textDirection: textDirection,
                      ),
                      const SizedBox(height: 6),
                    ],
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailsScreen(news: news),
                          ),
                        );
                      },
                      child: Text(
                        l10n.readMore,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.start,
                        textDirection: textDirection,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      relativeTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                      textAlign: TextAlign.start,
                      textDirection: textDirection,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _NewsThumbnail(imageUrl: news.imageUrl),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsThumbnail extends StatelessWidget {
  const _NewsThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFE5EBEF),
        ),
        child: const Icon(Icons.article_rounded, color: Color(0xFF54606B)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 72,
          height: 72,
          color: const Color(0xFFE5EBEF),
        ),
        errorWidget: (context, url, error) => Container(
          width: 72,
          height: 72,
          color: const Color(0xFFE5EBEF),
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}
