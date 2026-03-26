part of 'home_screen.dart';

class _VideoCategoriesSection extends StatelessWidget {
  const _VideoCategoriesSection({required this.future, required this.title});

  final Future<List<VideoCategoryModel>> future;
  final String title;

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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        FutureBuilder<List<VideoCategoryModel>>(
          future: future,
          builder: (context, snapshot) {
            final categories = snapshot.data ?? const <VideoCategoryModel>[];

            if (snapshot.hasError && categories.isEmpty) {
              return _SectionMessage(
                text: l10n.failedLoadVideos(snapshot.error.toString()),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                categories.isEmpty) {
              return SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder:
                      (context, index) => const ShimmerLoading(
                        width: 180,
                        height: 120,
                        borderRadius: 14,
                      ),
                ),
              );
            }

            if (categories.isEmpty) {
              return _SectionMessage(text: l10n.noVideosNow);
            }

            return SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder:
                    (context, index) =>
                        _VideoCategoryCard(category: categories[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VideoCategoryCard extends StatelessWidget {
  const _VideoCategoryCard({required this.category});

  final VideoCategoryModel category;

  @override
  Widget build(BuildContext context) {
    final hasCover =
        category.coverImageUrl != null && category.coverImageUrl!.isNotEmpty;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 3.0);
    final cacheWidth = (180 * pixelRatio).round();
    final cacheHeight = (120 * pixelRatio).round();
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.video_library_rounded, size: 30),
    );

    return SizedBox(
      width: 180,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => VideosScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasCover)
                CachedNetworkImage(
                  imageUrl: category.coverImageUrl!,
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
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
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
    return Column(children: items.map((item) => NewsCard(news: item)).toList());
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
