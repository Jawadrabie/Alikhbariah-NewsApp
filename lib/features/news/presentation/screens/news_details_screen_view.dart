part of 'news_details_screen.dart';

extension _NewsDetailsScreenView on _NewsDetailsScreenState {
  String _formatViewCount(BuildContext context, int count) {
    final localeName = Localizations.localeOf(context).toString();
    return intl.NumberFormat.compact(locale: localeName).format(count);
  }

  /// حساب الفرق بالأيام بين موعد الخبر والآن
  int _daysDifference(DateTime publishedAt) {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    return difference.inDays;
  }

  /// تحديد ما إذا كان يتم عرض التاريخ النسبي أم التاريخ الكامل
  /// true = عرض الوقت النسبي فقط (منذ يومين، منذ يوم، إلخ)
  /// false = عرض التاريخ الكامل فقط
  bool _shouldShowRelativeTime(DateTime publishedAt) {
    return _daysDifference(publishedAt) <= 2;
  }

  Widget _buildScaffold(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = widget.news.title;
    final content = widget.news.content;
    final imageUrl = widget.news.imageUrl;
    final publishedAt = widget.news.createdAt;
    final localeName = Localizations.localeOf(context).toString();
    final formattedDate = intl.DateFormat(
      'yyyy/MM/dd - HH:mm',
      localeName,
    ).format(publishedAt);
    final relativeDate = formatRelativeTime(context, publishedAt);
    final governorate = _governorateName;
    final compactViews = _formatViewCount(context, _viewCount);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Text(
              l10n.articleDetails,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
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
                icon: const Icon(Icons.share_outlined),
                onPressed: _shareArticle,
                tooltip: l10n.share,
              ),
              IconButton(
                icon: Icon(
                  _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
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
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        placeholder:
                            (_, __) => const ShimmerLoading(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: 0,
                            ),
                        errorWidget:
                            (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50),
                            ),
                      )
                    else
                      Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.article_rounded,
                          size: 72,
                          color: Colors.grey,
                        ),
                      ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black45,
                            Colors.transparent,
                            Colors.black87,
                          ],
                          stops: [0.0, 0.45, 1.0],
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
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_shouldShowRelativeTime(publishedAt)) ...[
                            // عرض الوقت النسبي فقط (اقل من او يساوي يومين)
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              relativeDate,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ] else ...[
                            // عرض التاريخ الكامل فقط (اكثر من يومين)
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedDate,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: CircleAvatar(
                              radius: 2,
                              backgroundColor: scheme.onSurfaceVariant,
                            ),
                          ),
                          Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            compactViews,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (governorate != null &&
                              governorate.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer.withValues(
                                  alpha: 0.4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 14,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    governorate,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Directionality(
                      textDirection: Directionality.of(context),
                      child: HtmlWidget(
                        content,
                        textStyle: TextStyle(
                          fontSize: _fontSize,
                          height: 1.8,
                          color: scheme.onSurface,
                        ),
                        onTapUrl: (url) async {
                          if (!await launchUrl(Uri.parse(url))) {
                            throw Exception(l10n.openLinkFailed);
                          }
                          return true;
                        },
                      ),
                    ),
                    if (_relatedLoading || _relatedNews.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.relatedNews,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_relatedLoading)
                        const _RelatedNewsLoading()
                      else
                        Column(
                          children: [
                            for (var i = 0; i < _relatedNews.length; i++)
                              _RelatedNewsTile(
                                news: _relatedNews[i],
                                isLast: i == _relatedNews.length - 1,
                              ),
                          ],
                        ),
                    ],
                    const SizedBox(height: 40),
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
