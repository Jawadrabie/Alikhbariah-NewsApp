part of 'videos_screen.dart';

String _videoAgoLabel(Duration elapsed, String localeName) {
  final isEnglish = localeName.toLowerCase().startsWith('en');

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

String _videoDateTimeLabel(DateTime value, String localeName) {
  final now = DateTime.now();
  final elapsed = now.isAfter(value) ? now.difference(value) : Duration.zero;

  if (elapsed < const Duration(hours: 24)) {
    return _videoAgoLabel(elapsed, localeName);
  }

  final datePart = intl.DateFormat('d MMM', localeName).format(value);
  final timePart = intl.DateFormat.Hm(localeName).format(value);
  return '$datePart • $timePart';
}

extension _VideosScreenView on _VideosScreenState {
  Widget _buildEpisodesView(BuildContext context) {
    final l10n = context.l10n;
    final localeCode =
        Localizations.localeOf(context).languageCode.toLowerCase();
    final title =
        widget.showLatestVideos
            ? (widget.latestVideosTitle ??
                (localeCode == 'en' ? 'Latest Videos' : 'آخر الفيديوهات'))
            : (widget.categoryName != null
                ? widget.categoryName!
                : (widget.programName == null
                    ? l10n.videos
                    : l10n.programEpisodes(widget.programName!)));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<VideoItemModel>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <VideoItemModel>[];

          if (snapshot.hasError && items.isEmpty) {
            return Center(
              child: Text(l10n.failedLoadVideos(snapshot.error.toString())),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return Center(child: Text(l10n.noVideosNow));
          }

          return ListView.separated(
            padding:
                widget.showLatestVideos
                    ? const EdgeInsets.fromLTRB(0, 12, 0, 20)
                    : const EdgeInsets.fromLTRB(16, 12, 16, 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (widget.showLatestVideos) {
                return _buildLatestVideoWideCard(
                  context: context,
                  item: items[index],
                  allItems: items,
                  index: index,
                  listTitle: title,
                );
              }

              return _buildEpisodeCard(
                context: context,
                item: items[index],
                allItems: items,
                index: index,
                listTitle: title,
                showSequenceLabel: true,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoriesView(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.videos)),
      body: FutureBuilder<List<VideoCategoryModel>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          final categories = snapshot.data ?? const <VideoCategoryModel>[];

          if (snapshot.hasError && categories.isEmpty) {
            return Center(
              child: Text(l10n.failedLoadVideos(snapshot.error.toString())),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (categories.isEmpty) {
            return Center(child: Text(l10n.noVideosNow));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder:
                (context, index) => _buildCategoryCard(categories[index]),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(VideoCategoryModel category) {
    final direction = Directionality.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 1,
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
        child: SizedBox(
          height: 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              category.coverImageUrl == null || category.coverImageUrl!.isEmpty
                  ? Container(
                    color: const Color(0xFFE5EBEF),
                    child: const Icon(
                      Icons.video_library_rounded,
                      size: 44,
                      color: Color(0xFF4B5563),
                    ),
                  )
                  : CachedNetworkImage(
                    imageUrl: category.coverImageUrl!,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    placeholder:
                        (_, __) => Container(
                          color: const Color(0xFFE5EBEF),
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    errorWidget:
                        (_, __, ___) => Container(
                          color: const Color(0xFFE5EBEF),
                          child: const Icon(
                            Icons.video_library_rounded,
                            size: 44,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                  ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x22000000), Color(0xA6000000)],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                left: 12,
                bottom: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: direction,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.white,
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

  Widget _buildEpisodeCard({
    required BuildContext context,
    required VideoItemModel item,
    required List<VideoItemModel> allItems,
    required int index,
    required String listTitle,
    required bool showSequenceLabel,
  }) {
    final direction = Directionality.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final thumb = _thumbnailOf(item);
    final publishedOn = item.publishedAt ?? item.createdAt;
    final now = DateTime.now();
    final elapsed =
        now.isAfter(publishedOn) ? now.difference(publishedOn) : Duration.zero;
    final isRecent = elapsed < const Duration(hours: 24);
    final dateLabel = intl.DateFormat('d MMM', localeName).format(publishedOn);
    final timeLabel = intl.DateFormat.Hm(localeName).format(publishedOn);
    final chipLabel =
        isRecent ? _videoAgoLabel(elapsed, localeName) : dateLabel;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            () => _openEpisodePlayer(
              items: allItems,
              initialIndex: index,
              listTitle: listTitle,
            ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 152,
                  height: 86,
                  color: const Color(0xFFE5EBEF),
                  child:
                      thumb.isEmpty
                          ? const Icon(Icons.play_circle_fill_rounded)
                          : CachedNetworkImage(
                            imageUrl: thumb,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            placeholder:
                                (_, __) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (_, __, ___) =>
                                    const Icon(Icons.play_circle_fill_rounded),
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSequenceLabel) ...[
                      Text(
                        '${_episodesLabel(context)} ${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: direction,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textDirection: direction,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  chipLabel,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  textDirection: direction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestVideoWideCard({
    required BuildContext context,
    required VideoItemModel item,
    required List<VideoItemModel> allItems,
    required int index,
    required String listTitle,
  }) {
    final direction = Directionality.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final thumb = _thumbnailOf(item);
    final publishedOn = item.publishedAt ?? item.createdAt;
    final dateTimeLabel = _videoDateTimeLabel(publishedOn, localeName);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 3.0);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cacheWidth = (screenWidth * pixelRatio).round();
    final cacheHeight = (208 * pixelRatio).round();
    final placeholder = Container(
      color: const Color(0xFFE5EBEF),
      alignment: Alignment.center,
      child: const Icon(Icons.play_circle_fill_rounded, size: 40),
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            () => _openEpisodePlayer(
              items: allItems,
              initialIndex: index,
              listTitle: listTitle,
            ),
        child: SizedBox(
          height: 208,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumb.isEmpty)
                placeholder
              else
                CachedNetworkImage(
                  imageUrl: thumb,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  memCacheWidth: cacheWidth,
                  memCacheHeight: cacheHeight,
                  maxWidthDiskCache: cacheWidth,
                  maxHeightDiskCache: cacheHeight,
                  placeholder: (_, __) => placeholder,
                  errorWidget: (_, __, ___) => placeholder,
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: Container(
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                start: 14,
                end: 14,
                bottom: 12,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Color(0x90000000),
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
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
                              fontSize: 12,
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
                  size: 40,
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
