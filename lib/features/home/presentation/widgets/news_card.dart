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
    if (plain.length <= 72) return plain;
    return '${plain.substring(0, 72)}...';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textDirection = Directionality.of(context);
    final relativeTime = formatRelativeTime(context, news.createdAt);
    final preview = _contentPreview(news.content);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
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
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          relativeTime,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.start,
                          textDirection: textDirection,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                      textAlign: TextAlign.start,
                      textDirection: textDirection,
                    ),
                    const SizedBox(height: 6),
                    if (preview.isNotEmpty) ...[
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$preview ',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                            TextSpan(
                              text: l10n.readMore,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        textDirection: textDirection,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFE5EBEF),
        ),
        child: const Icon(Icons.article_rounded, color: Color(0xFF54606B)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: 92,
        height: 92,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 92,
          height: 92,
          color: const Color(0xFFE5EBEF),
        ),
        errorWidget: (context, url, error) => Container(
          width: 92,
          height: 92,
          color: const Color(0xFFE5EBEF),
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}
