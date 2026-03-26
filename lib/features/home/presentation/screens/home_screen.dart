import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/utils/image_prefetch_guard.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../media/data/models/video_category_model.dart';
import '../../../media/data/repositories/media_repository.dart';
import '../../../media/presentation/screens/videos_screen.dart';
import '../../data/models/breaking_news_headline_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/featured_slider_settings_model.dart';
import '../../data/models/news_model.dart';
import '../../data/repositories/home_repository.dart';
import '../widgets/breaking_ticker.dart';
import '../widgets/category_chips.dart';
import '../widgets/featured_slider.dart';
import '../widgets/home_drawer.dart';
import '../widgets/news_card.dart';

part 'home_screen_search.dart';
part 'home_screen_app_bar.dart';
part 'home_screen_data_loading.dart';
part 'home_screen_news_loading.dart';
part 'home_screen_primary_sections.dart';
part 'home_screen_secondary_sections.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _pageSize = 10;

  final HomeRepository _repository = HomeRepository();
  final MediaRepository _mediaRepository = MediaRepository();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<NewsModel>> _featuredFuture;
  late Future<List<VideoCategoryModel>> _videoCategoriesFuture;
  late Future<FeaturedSliderSettingsModel> _sliderSettingsFuture;

  List<NewsModel> _latestNews = const [];
  List<NewsModel> _categoryNews = const [];
  List<BreakingNewsHeadlineModel> _breakingHeadlines = const [];
  final Set<int> _trackedBreakingViewIds = <int>{};
  bool _isInitialNewsLoading = true;
  bool _isLoadingMore = false;
  bool _isCategoryNewsLoading = false;
  bool _hasMoreNews = true;
  int _offset = 0;
  int? _selectedCategoryId;
  String _currentLanguageCode = 'ar';

  @override
  void initState() {
    super.initState();
    _categoriesFuture = Future.value(const <CategoryModel>[]);
    _featuredFuture = Future.value(const <NewsModel>[]);
    _videoCategoriesFuture = Future.value(const <VideoCategoryModel>[]);
    _sliderSettingsFuture = Future.value(
      const FeaturedSliderSettingsModel(autoplay: false, intervalSeconds: 0),
    );
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode =
        Localizations.localeOf(context).languageCode.toLowerCase();

    if (_currentLanguageCode == languageCode) {
      return;
    }

    _currentLanguageCode = languageCode;
    _loadData();

    if (_selectedCategoryId != null) {
      _onCategorySelected(_selectedCategoryId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PopScope(
      canPop: _selectedCategoryId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _selectedCategoryId == null) return;
        _onCategorySelected(null);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        endDrawer: const HomeDrawer(),
        appBar: _buildAppBar(l10n),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            controller: _scrollController,
            children: _buildContent(l10n),
          ),
        ),
      ),
    );
  }
}
