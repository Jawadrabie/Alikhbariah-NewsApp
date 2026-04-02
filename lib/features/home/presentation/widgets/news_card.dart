import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/utils/relative_time_formatter.dart';
import '../../../../features/news/presentation/screens/news_details_screen.dart';
import '../../data/models/news_model.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.news,
    this.isFullWidth = false,
  });

  static const double _thumbnailWidth = 132;
  static const int _thumbnailMemCacheWidth = 320;
  static const int _thumbnailMemCacheHeight = 232;
  static const int _thumbnailDiskCacheWidth = 420;
  static const int _thumbnailDiskCacheHeight = 304;

  final NewsModel news;
  final bool isFullWidth;

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

  String _formatViewCount(BuildContext context, int count) {
    final localeName = Localizations.localeOf(context).toString();
    return intl.NumberFormat.compact(locale: localeName).format(count);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final textDirection = Directionality.of(context);
    final relativeTime = formatRelativeTime(context, news.createdAt);
    final compactViews = _formatViewCount(context, news.viewCount);
    final preview = _contentPreview(news.content);

    return Container(
      margin: EdgeInsets.fromLTRB(isFullWidth ? 0 : 16, 8, isFullWidth ? 0 : 16, 8),
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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  12,
                  12,
                  NewsCard._thumbnailWidth + 24,
                  12,
                ),
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
                        const SizedBox(width: 10),
                        Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          compactViews,
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
              PositionedDirectional(
                top: 0,
                bottom: 0,
                end: 0,
                width: NewsCard._thumbnailWidth,
                child: _NewsThumbnail(
                  imageUrl: news.imageUrl,
                  heroTag: 'news_image_${news.id}',
                ),
              ),
            ],
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
    final thumbnailRadius =
        const BorderRadiusDirectional.only(
          topEnd: Radius.circular(16),
          bottomEnd: Radius.circular(16),
        ).resolve(Directionality.of(context));

    if (imageUrl == null || imageUrl!.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: thumbnailRadius,
          color: backgroundColor,
        ),
        child: const Center(
          child: Icon(Icons.article_rounded, color: Colors.grey),
        ),
      );
    }

    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: thumbnailRadius,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
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
                child: const SizedBox.expand(),
              ),
          errorWidget:
              (_, __, ___) => ColoredBox(
                color: backgroundColor,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
