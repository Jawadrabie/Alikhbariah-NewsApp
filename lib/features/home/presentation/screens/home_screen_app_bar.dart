part of 'home_screen.dart';

extension _HomeScreenView on _HomeScreenState {
  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      iconTheme: IconThemeData(color: scheme.onSurface),
      actionsIconTheme: IconThemeData(color: scheme.onSurface),
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/logo.webp',
            height: 38,
            fit: BoxFit.contain,
          ),
        ],
      ),
      bottom:
          _breakingHeadlines.isEmpty
              ? null
              : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: _BreakingTickerHeader(
                  titles: _breakingHeadlines.map((item) => item.title).toList(),
                ),
              ),
      actions: [
        IconButton(
          onPressed:
              () => showSearch<void>(
                context: context,
                delegate: _NewsSearchDelegate(
                  repository: _repository,
                  languageCode: _currentLanguageCode,
                ),
              ),
          icon: const Icon(Icons.search_rounded),
          tooltip: l10n.search,
        ),
        IconButton(
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          icon: const Icon(Icons.menu_rounded),
        ),
      ],
    );
  }

  List<Widget> _buildContent(AppLocalizations l10n) {
    final content = <Widget>[
      _HomeCategoriesStrip(
        future: _categoriesFuture,
        selectedCategoryId: _selectedCategoryId,
        onCategorySelected: _onCategorySelected,
      ),
    ];

    if (_selectedCategoryId != null) {
      content.add(
        _CategoryNewsSection(
          title: l10n.latestNews,
          isLoading: _isCategoryNewsLoading,
          items: _categoryNews,
          emptyText: l10n.noNewsNow,
        ),
      );
      return content;
    }

    content.addAll([
      _FeaturedNewsSection(
        newsFuture: _featuredFuture,
        settingsFuture: _sliderSettingsFuture,
      ),
      _VideoCategoriesSection(
        future: _videoCategoriesFuture,
        title: l10n.videos,
      ),
      _LatestNewsSection(
        title: l10n.latestNews,
        items: _latestNews,
        isInitialLoading: _isInitialNewsLoading,
        isLoadingMore: _isLoadingMore,
        hasMore: _hasMoreNews,
        emptyText: l10n.noNewsNow,
        allShownText: l10n.allNewsShown,
      ),
      const SizedBox(height: 12),
    ]);

    return content;
  }
}
