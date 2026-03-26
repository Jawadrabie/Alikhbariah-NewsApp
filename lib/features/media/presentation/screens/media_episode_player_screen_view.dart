// ignore_for_file: invalid_use_of_protected_member

part of 'media_episode_player_screen.dart';

extension _MediaEpisodePlayerScreenView on _MediaEpisodePlayerScreenState {
  Widget _buildScreen(BuildContext context) {
    final direction = Directionality.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final mediaQuery = MediaQuery.of(context);
    final isLandscapeFullscreen =
        _isExpandedPlayer && mediaQuery.orientation == Orientation.landscape;
    final showInlinePlayer = !_isInlinePlayerMinimized;
    final normalHeight = mediaQuery.size.width * 9 / 16;
    final expandedHeight = mediaQuery.size.height.toDouble();
    final playerHeight = _isExpandedPlayer ? expandedHeight : normalHeight;

    return Scaffold(
      backgroundColor:
          isLandscapeFullscreen
              ? Colors.black
              : Theme.of(context).scaffoldBackgroundColor,
      appBar:
          isLandscapeFullscreen ? null : AppBar(title: Text(widget.listTitle)),
      body:
          isLandscapeFullscreen
              ? Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black, child: _buildPlayer()),
                  if (_playbackError != null)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text(
                        _playbackError!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  _buildOverlayControls(),
                ],
              )
              : Column(
                children: [
                  if (showInlinePlayer)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: playerHeight,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: Colors.black, child: _buildPlayer()),
                          if (_playbackError != null)
                            Container(
                              color: Colors.black54,
                              alignment: Alignment.center,
                              child: Text(
                                _playbackError!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          _buildOverlayControls(),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentEpisode.title,
                          textDirection: direction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _episodesLabel(context),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: widget.episodes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = widget.episodes[index];
                        final thumb = _thumbnailOf(item);
                        final date = intl.DateFormat(
                          'yyyy-MM-dd - HH:mm',
                          localeName,
                        ).format(item.publishedAt ?? item.createdAt);
                        final selected = index == _currentIndex;

                        return Card(
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          color:
                              selected
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(18)
                                  : null,
                          child: InkWell(
                            onTap: () {
                              if (_currentIndex == index) return;
                              setState(() {
                                _currentIndex = index;
                              });
                              if (_isInlinePlayerMinimized) {
                                final didStart = InAppVideoController.instance
                                    .prepareInline(
                                      youtubeUrl: item.youtubeUrl,
                                      title: item.title,
                                    );
                                if (didStart) {
                                  InAppVideoController.instance.minimize();
                                }
                                return;
                              }
                              _loadCurrentEpisode();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 124,
                                      height: 78,
                                      color: const Color(0xFFE5EBEF),
                                      child:
                                          thumb.isEmpty
                                              ? const Icon(
                                                Icons.play_circle_fill_rounded,
                                              )
                                              : CachedNetworkImage(
                                                imageUrl: thumb,
                                                fit: BoxFit.cover,
                                                placeholder:
                                                    (_, __) => const Center(
                                                      child: SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (_, __, ___) => const Icon(
                                                      Icons
                                                          .play_circle_fill_rounded,
                                                    ),
                                              ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          textDirection: direction,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          date,
                                          textDirection: direction,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    selected
                                        ? Icons.play_circle_filled_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
