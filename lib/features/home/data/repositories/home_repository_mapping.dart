part of 'home_repository.dart';

List<CategoryModel> _mapCategories(
  List<Map<String, dynamic>> rows, {
  required String languageCode,
}) {
  return rows
      .map((item) => CategoryModel.fromJson(item, languageCode: languageCode))
      .toList();
}

List<NewsModel> _mapNews(
  List<Map<String, dynamic>> rows, {
  required String languageCode,
}) {
  return rows
      .map((item) => NewsModel.fromJson(item, languageCode: languageCode))
      .toList();
}

List<String> _mapBreakingTitles(
  List<Map<String, dynamic>> rows, {
  required String languageCode,
}) {
  final fallbackLanguage = languageCode == 'en' ? 'ar' : 'en';

  return rows
      .map(
        (item) =>
            _readText(item['title_$languageCode']) ??
            _readText(item['title']) ??
            _readText(item['title_$fallbackLanguage']) ??
            '',
      )
      .where((title) => title.trim().isNotEmpty)
      .toList();
}

List<BreakingNewsHeadlineModel> _mapBreakingHeadlines(
  List<Map<String, dynamic>> rows, {
  required String languageCode,
}) {
  final fallbackLanguage = languageCode == 'en' ? 'ar' : 'en';

  return rows
      .map((item) {
        final id = (item['id'] as num?)?.toInt();
        final title =
            _readText(item['title_$languageCode']) ??
            _readText(item['title']) ??
            _readText(item['title_$fallbackLanguage']) ??
            '';

        if (id == null || title.trim().isEmpty) {
          return null;
        }

        return BreakingNewsHeadlineModel(id: id, title: title);
      })
      .whereType<BreakingNewsHeadlineModel>()
      .toList();
}

PostgrestFilterBuilder<List<Map<String, dynamic>>> _newsBaseQuery(
  SupabaseClient client,
) {
  return client
      .from('news')
      .select('*, location:locations(name,name_en)')
      .eq('is_hidden', false);
}

String _sanitizeSearchTerm(String value) {
  return value
      .replaceAll(',', ' ')
      .replaceAll('(', ' ')
      .replaceAll(')', ' ')
      .trim();
}

String? _readText(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

FeaturedSliderSettingsModel _settingsFromMap(
  Map<String, dynamic> map, {
  required int defaultInterval,
}) {
  final values = map.map(
    (key, value) => MapEntry(key, value?.toString() ?? ''),
  );

  final autoplay =
      (values['featured_slider_autoplay']?.toLowerCase() ?? 'true') == 'true';
  final interval =
      int.tryParse(
        values['featured_slider_interval_seconds'] ?? '$defaultInterval',
      ) ??
      defaultInterval;

  return FeaturedSliderSettingsModel(
    autoplay: autoplay,
    intervalSeconds: interval < 1 ? defaultInterval : interval,
  );
}

List<Map<String, dynamic>> _toMapList(dynamic response) {
  return (response as List<dynamic>)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
}
