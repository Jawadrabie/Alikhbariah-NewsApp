part of 'videos_screen.dart';

extension _VideosScreenView on _VideosScreenState {
  Widget _buildEpisodesView(BuildContext context) {
    final l10n = context.l10n;
    final title =
        widget.categoryName != null
            ? widget.categoryName!
            : (widget.programName == null
                ? l10n.videos
                : l10n.programEpisodes(widget.programName!));

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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder:
                (context, index) => _buildEpisodeCard(
                  context: context,
                  item: items[index],
                  allItems: items,
                  index: index,
                  listTitle: title,
                ),
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
  }) {
    final direction = Directionality.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final thumb = _thumbnailOf(item);
    final date = intl.DateFormat(
      'yyyy-MM-dd – HH:mm',
      localeName,
    ).format(item.publishedAt ?? item.createdAt);

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
                  width: 132,
                  height: 84,
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
                    Text(
                      '${_episodesLabel(context)} ${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: direction,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                      textDirection: direction,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.play_arrow_rounded, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
