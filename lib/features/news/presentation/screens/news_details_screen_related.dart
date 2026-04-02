part of 'news_details_screen.dart';

class _RelatedNewsLoading extends StatelessWidget {
  const _RelatedNewsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _RelatedNewsLoadingItem(),
        SizedBox(height: 10),
        _RelatedNewsLoadingItem(),
        SizedBox(height: 10),
        _RelatedNewsLoadingItem(),
      ],
    );
  }
}

class _RelatedNewsLoadingItem extends StatelessWidget {
  const _RelatedNewsLoadingItem();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 102,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const ShimmerLoading(
        width: double.infinity,
        height: 102,
        borderRadius: 14,
      ),
    );
  }
}

class _RelatedNewsTile extends StatelessWidget {
  const _RelatedNewsTile({required this.news, required this.isLast});

  final NewsModel news;
  final bool isLast;

  String _contentPreview(String htmlContent) {
    final plain =
        htmlContent
            .replaceAll(RegExp(r'<[^>]*>'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    if (plain.isEmpty) return '';
    if (plain.length <= 95) return plain;
    return '${plain.substring(0, 95)}...';
  }

  String _formatViewCount(BuildContext context, int count) {
    final localeName = Localizations.localeOf(context).toString();
    return intl.NumberFormat.compact(locale: localeName).format(count);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final direction = Directionality.of(context);
    final preview = _contentPreview(news.content);
    final relativeTime = formatRelativeTime(context, news.createdAt);
    final compactViews = _formatViewCount(context, news.viewCount);
    final location = news.locationName?.trim();
    final isRtl = direction == TextDirection.rtl;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NewsDetailsScreen(news: news)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RelatedThumbnail(imageUrl: news.imageUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          fontSize: 14.5,
                        ),
                      ),
                      if (preview.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.75),
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _RelatedMetaLabel(
                            icon: Icons.schedule_rounded,
                            text: relativeTime,
                          ),
                          _RelatedMetaLabel(
                            icon: Icons.visibility_outlined,
                            text: compactViews,
                          ),
                          if (location != null && location.isNotEmpty)
                            _RelatedMetaLabel(
                              icon: Icons.location_on_outlined,
                              text: location,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isRtl
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: scheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RelatedMetaLabel extends StatelessWidget {
  const _RelatedMetaLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: scheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.8,
            fontWeight: FontWeight.w600,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}

class _RelatedThumbnail extends StatelessWidget {
  const _RelatedThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.article_rounded, color: Colors.grey, size: 24),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: 84,
        height: 84,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder:
            (_, __) =>
                const ShimmerLoading(width: 84, height: 84, borderRadius: 12),
        errorWidget:
            (_, __, ___) => Container(
              width: 84,
              height: 84,
              color: scheme.surfaceContainerHighest,
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
                size: 24,
              ),
            ),
      ),
    );
  }
}
