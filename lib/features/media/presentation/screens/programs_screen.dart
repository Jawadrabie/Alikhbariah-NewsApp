import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../data/models/video_category_model.dart';
import '../../data/repositories/media_repository.dart';
import 'videos_screen.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final MediaRepository _repository = MediaRepository();
  late Future<List<VideoCategoryModel>> _programsFuture;
  String _currentLanguageCode = 'ar';

  @override
  void initState() {
    super.initState();
    _programsFuture = Future.value(const <VideoCategoryModel>[]);
    _loadPrograms();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextLanguage =
        Localizations.localeOf(context).languageCode.toLowerCase();
    if (_currentLanguageCode == nextLanguage) {
      return;
    }
    _currentLanguageCode = nextLanguage;
    _loadPrograms();
  }

  void _loadPrograms() {
    _programsFuture = _seedFutureFromCache(
      cachedValue: _repository.getCachedVideoCategories(
        languageCode: _currentLanguageCode,
        categoryType: 'program',
      ),
      assign: (future) => _programsFuture = future,
      load:
          (forceRefresh) => _repository.getVideoCategories(
            languageCode: _currentLanguageCode,
            categoryType: 'program',
            forceRefresh: forceRefresh,
          ),
    );
  }

  Future<T> _seedFutureFromCache<T>({
    required T? cachedValue,
    required void Function(Future<T> future) assign,
    required Future<T> Function(bool forceRefresh) load,
  }) {
    if (cachedValue != null) {
      load(true).then((fresh) {
        if (!mounted) return;
        setState(() {
          assign(Future.value(fresh));
        });
      });
      return Future.value(cachedValue);
    }

    return load(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.programs)),
      body: FutureBuilder<List<VideoCategoryModel>>(
        future: _programsFuture,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <VideoCategoryModel>[];

          if (snapshot.hasError && items.isEmpty) {
            return Center(
              child: Text(l10n.failedLoadPrograms(snapshot.error.toString())),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return Center(child: Text(l10n.noProgramsNow));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
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
                              categoryId: item.id,
                              categoryName: item.name,
                            ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 128,
                            height: 82,
                            color: const Color(0xFFE5EBEF),
                            child:
                                item.coverImageUrl == null ||
                                        item.coverImageUrl!.isEmpty
                                    ? const Icon(
                                      Icons.video_collection_rounded,
                                      size: 30,
                                    )
                                    : CachedNetworkImage(
                                      imageUrl: item.coverImageUrl!,
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
                                          (_, __, ___) => const Icon(
                                            Icons.video_collection_rounded,
                                            size: 30,
                                          ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                textDirection: direction,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
