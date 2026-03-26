part of 'home_screen.dart';

class _NewsSearchDelegate extends SearchDelegate<void> {
  _NewsSearchDelegate({
    required HomeRepository repository,
    required String languageCode,
  }) : _repository = repository,
       _languageCode = languageCode;

  final HomeRepository _repository;
  final String _languageCode;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _NewsSearchResults(
      query: query,
      repository: _repository,
      languageCode: _languageCode,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _NewsSearchResults(
      query: query,
      repository: _repository,
      languageCode: _languageCode,
    );
  }
}

class _NewsSearchResults extends StatelessWidget {
  const _NewsSearchResults({
    required this.query,
    required this.repository,
    required this.languageCode,
  });

  final String query;
  final HomeRepository repository;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return Center(
        child: Text(l10n.search, style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return FutureBuilder<List<NewsModel>>(
      future: repository.getLatestNews(
        languageCode: languageCode,
        limit: 50,
        searchQuery: normalizedQuery,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(snapshot.error.toString()),
          );
        }

        final items = snapshot.data ?? const <NewsModel>[];
        if (items.isEmpty) {
          return Center(child: Text(l10n.noNewsNow));
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return NewsCard(news: items[index]);
          },
        );
      },
    );
  }
}
