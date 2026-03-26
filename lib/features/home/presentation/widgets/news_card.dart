import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/utils/relative_time_formatter.dart';
import '../../../../features/news/presentation/screens/news_details_screen.dart';
import '../../data/models/news_model.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.news});

  static const double _thumbnailSize = 100;
  static const int _thumbnailMemCacheWidth = 240;
  static const int _thumbnailMemCacheHeight = 240;
  static const int _thumbnailDiskCacheWidth = 320;
  static const int _thumbnailDiskCacheHeight = 320;

  final NewsModel news;

  String _contentPreview(String htmlContent) {
    final plain =
        htmlContent
            .replaceAll(RegExp(r'<[^>]*>'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    if (plain.isEmpty) return '';
    if (plain.length <= 72) return plain;
    return '${plain.substring(0, 72)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final textDirection = Directionality.of(context);
    final relativeTime = formatRelativeTime(context, news.createdAt);
    final preview = _contentPreview(news.content);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailsScreen(news: news),
              ),
            );
          },
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
                            size: 14,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            relativeTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.start,
                            textDirection: textDirection,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.start,
                        textDirection: textDirection,
                      ),
                      if (preview.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$preview ',
                                style: TextStyle(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: l10n.readMore,
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
                const SizedBox(width: 16),
                _NewsThumbnail(
                  imageUrl: news.imageUrl,
                  heroTag: 'news_image_${news.id}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsThumbnail extends StatelessWidget {
  const _NewsThumbnail({required this.imageUrl, required this.heroTag});

  final String? imageUrl;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        Theme.of(context).colorScheme.surfaceContainerHighest;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: NewsCard._thumbnailSize,
        height: NewsCard._thumbnailSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: backgroundColor,
        ),
        child: const Icon(Icons.article_rounded, color: Colors.grey),
      );
    }

    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: NewsCard._thumbnailSize,
          height: NewsCard._thumbnailSize,
          fit: BoxFit.cover,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          useOldImageOnUrlChange: true,
          memCacheWidth: NewsCard._thumbnailMemCacheWidth,
          memCacheHeight: NewsCard._thumbnailMemCacheHeight,
          maxWidthDiskCache: NewsCard._thumbnailDiskCacheWidth,
          maxHeightDiskCache: NewsCard._thumbnailDiskCacheHeight,
          placeholder:
              (_, __) => ColoredBox(
                color: backgroundColor,
                child: const SizedBox.square(
                  dimension: NewsCard._thumbnailSize,
                ),
              ),
          errorWidget:
              (_, __, ___) => Container(
                width: NewsCard._thumbnailSize,
                height: NewsCard._thumbnailSize,
                color: backgroundColor,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                ),
              ),
        ),
      ),
    );
  }
}
