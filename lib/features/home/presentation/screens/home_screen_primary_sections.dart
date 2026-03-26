part of 'home_screen.dart';

class _BreakingTickerHeader extends StatelessWidget {
  const _BreakingTickerHeader({required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: BreakingTicker(
        titles: titles,
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}

class _HomeCategoriesStrip extends StatelessWidget {
  const _HomeCategoriesStrip({
    required this.future,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final Future<List<CategoryModel>> future;
  final int? selectedCategoryId;
  final Future<void> Function(int? categoryId, {bool forceRefresh})
  onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<List<CategoryModel>>(
      future: future,
      builder: (context, snapshot) {
        final categories = snapshot.data ?? const <CategoryModel>[];

        if (snapshot.hasError && categories.isEmpty) {
          return _SectionMessage(
            text: l10n.failedLoadCategories(snapshot.error.toString()),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            categories.isEmpty) {
          return const SizedBox(height: 52, child: CategoryChipsShimmer());
        }

        return CategoryChips(
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          onCategorySelected: onCategorySelected,
        );
      },
    );
  }
}

class _CategoryNewsSection extends StatelessWidget {
  const _CategoryNewsSection({
    required this.title,
    required this.isLoading,
    required this.items,
    required this.emptyText,
  });

  final String title;
  final bool isLoading;
  final List<NewsModel> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: title),
        if (isLoading && items.isEmpty)
          Column(children: List.generate(4, (_) => const NewsCardShimmer()))
        else if (items.isEmpty)
          _SectionMessage(text: emptyText)
        else
          Column(
            children: [
              _NewsList(items: items),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
      ],
    );
  }
}

class _FeaturedNewsSection extends StatelessWidget {
  const _FeaturedNewsSection({
    required this.newsFuture,
    required this.settingsFuture,
  });

  final Future<List<NewsModel>> newsFuture;
  final Future<FeaturedSliderSettingsModel> settingsFuture;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<List<NewsModel>>(
      future: newsFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <NewsModel>[];

        if (snapshot.hasError && items.isEmpty) {
          return _SectionMessage(
            text: l10n.failedLoadFeaturedNews(snapshot.error.toString()),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerLoading(
              width: double.infinity,
              height: 220,
              borderRadius: 14,
            ),
          );
        }

        return FutureBuilder<FeaturedSliderSettingsModel>(
          future: settingsFuture,
          builder: (context, settingsSnapshot) {
            final settings =
                settingsSnapshot.data ??
                const FeaturedSliderSettingsModel(
                  autoplay: true,
                  intervalSeconds: 3,
                );

            return FeaturedSlider(
              items: items,
              autoplay: settings.autoplay,
              interval: Duration(seconds: settings.intervalSeconds),
            );
          },
        );
      },
    );
  }
}
