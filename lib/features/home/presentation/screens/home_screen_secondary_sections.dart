part of 'home_screen.dart';

String _homeExtractYoutubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return '';

  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
  }

  if (uri.queryParameters.containsKey('v')) {
    return uri.queryParameters['v'] ?? '';
  }

  final segments = uri.pathSegments;
  final index = segments.indexOf('embed');
  if (index != -1 && segments.length > index + 1) {
    return segments[index + 1];
  }

  return '';
}

String _homeThumbnailOfVideo(VideoItemModel item) {
  if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty) {
    return item.thumbnailUrl!;
  }

  final id = _homeExtractYoutubeId(item.youtubeUrl);
  if (id.isEmpty) {
    return '';
  }

  return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
}

String _homeVideoDateTimeLabel(DateTime value, String localeName) {
  final now = DateTime.now();
  final elapsed = now.isAfter(value) ? now.difference(value) : Duration.zero;
  final isEnglish = localeName.toLowerCase().startsWith('en');

  if (elapsed < const Duration(hours: 24)) {
    if (elapsed.inMinutes < 1) {
      return isEnglish ? 'Just now' : 'الآن';
    }
    if (elapsed.inHours < 1) {
      final minutes = elapsed.inMinutes.clamp(1, 59);
      return isEnglish ? '$minutes min ago' : 'منذ $minutes دقيقة';
    }
    final hours = elapsed.inHours.clamp(1, 23);
    return isEnglish ? '$hours h ago' : 'منذ $hours ساعة';
  }

  final datePart = intl.DateFormat('d MMM', localeName).format(value);
  final timePart = intl.DateFormat.Hm(localeName).format(value);
  return '$datePart • $timePart';
}

class _LatestVideosHorizontalSection extends StatelessWidget {
  const _LatestVideosHorizontalSection({
    required this.future,
    required this.title,
    required this.viewAllText,
  });

  final Future<List<VideoItemModel>> future;
  final String title;
  final String viewAllText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const VideosScreen(showLatestVideos: true),
                    ),
                  );
                },
                child: Text(viewAllText),
              ),
            ],
          ),
        ),
        FutureBuilder<List<VideoItemModel>>(
          future: future,
          builder: (context, snapshot) {
            final videos = snapshot.data ?? const <VideoItemModel>[];

            if (snapshot.hasError && videos.isEmpty) {
              return _SectionMessage(
                text: l10n.failedLoadVideos(snapshot.error.toString()),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                videos.isEmpty) {
              return SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder:
                      (context, index) => const ShimmerLoading(
                        width: 300,
                        height: 170,
                        borderRadius: 14,
                      ),
                ),
              );
            }

            if (videos.isEmpty) {
              return _SectionMessage(text: l10n.noVideosNow);
            }

            return SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: videos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _LatestVideoCard(
                    item: videos[index],
                    allItems: videos,
                    index: index,
                    listTitle: title,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LatestVideoCard extends StatelessWidget {
  const _LatestVideoCard({
    required this.item,
    required this.allItems,
    required this.index,
    required this.listTitle,
  });

  final VideoItemModel item;
  final List<VideoItemModel> allItems;
  final int index;
  final String listTitle;

  @override
  Widget build(BuildContext context) {
    final thumb = _homeThumbnailOfVideo(item);
    final hasCover = thumb.isNotEmpty;
    final localeName = Localizations.localeOf(context).toString();
    final publishedOn = item.publishedAt ?? item.createdAt;
    final direction = Directionality.of(context);
    final dateTimeLabel = _homeVideoDateTimeLabel(publishedOn, localeName);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 3.0);
    final cacheWidth = (300 * pixelRatio).round();
    final cacheHeight = (170 * pixelRatio).round();
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.play_circle_fill_rounded, size: 34),
    );

    return SizedBox(
      width: 300,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => MediaEpisodePlayerScreen(
                      episodes: allItems,
                      initialIndex: index,
                      listTitle: listTitle,
                    ),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasCover)
                CachedNetworkImage(
                  imageUrl: thumb,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  useOldImageOnUrlChange: true,
                  memCacheWidth: cacheWidth,
                  memCacheHeight: cacheHeight,
                  maxWidthDiskCache: cacheWidth,
                  maxHeightDiskCache: cacheHeight,
                  placeholder: (_, __) => placeholder,
                  errorWidget: (_, __, ___) => placeholder,
                )
              else
                placeholder,
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: Container(
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: 10,
                end: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: direction,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Color(0x90000000),
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: Color(0xFFE5E7EB),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dateTimeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: direction,
                            style: const TextStyle(
                              color: Color(0xFFE5E7EB),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 36,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Color(0x80000000),
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestNewsSection extends StatelessWidget {
  const _LatestNewsSection({
    required this.title,
    required this.items,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.emptyText,
    required this.allShownText,
  });

  final String title;
  final List<NewsModel> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String emptyText;
  final String allShownText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: title),
        if (isInitialLoading)
          Column(children: List.generate(5, (_) => const NewsCardShimmer()))
        else if (items.isEmpty)
          _SectionMessage(text: emptyText)
        else
          _NewsList(items: items),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        if (!isInitialLoading && !hasMore && items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                allShownText,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ),
      ],
    );
  }
}

class _NewsList extends StatelessWidget {
  const _NewsList({required this.items});

  final List<NewsModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
        return NewsCard(news: item);
      }).toList(),
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text),
    );
  }
}
