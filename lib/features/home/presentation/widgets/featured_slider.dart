import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer_loading.dart';
import '../../data/models/news_model.dart';
import '../../../news/presentation/screens/news_details_screen.dart';

class FeaturedSlider extends StatefulWidget {
  const FeaturedSlider({
    super.key,
    required this.items,
    this.autoplay = true,
    this.interval = const Duration(seconds: 3),
  });

  final List<NewsModel> items;
  final bool autoplay;
  final Duration interval;

  @override
  State<FeaturedSlider> createState() => _FeaturedSliderState();
}

class _FeaturedSliderState extends State<FeaturedSlider> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.93);
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant FeaturedSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length || oldWidget.autoplay != widget.autoplay) {
      _timer?.cancel();
      _index = 0;
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (!widget.autoplay || widget.items.length < 2) return;

    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || !_controller.hasClients) return;
      _index = (_index + 1) % widget.items.length;
      _controller.animateToPage(
        _index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
                child: _FeaturedCard(news: item),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
            (dotIndex) => Container(
              width: dotIndex == _index ? 18 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: dotIndex == _index
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.news});

  final NewsModel news;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewsDetailsScreen(news: news)),
          );
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: news.imageUrl == null || news.imageUrl!.isEmpty
                  ? const ColoredBox(color: Color(0xFFE5EBEF))
                  : CachedNetworkImage(
                      imageUrl: news.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerLoading(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 0,
                      ),
                      errorWidget: (context, url, error) => const ColoredBox(
                        color: Color(0xFFE5EBEF),
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(10),
                      Colors.black.withAlpha(160),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 12,
              end: 12,
              bottom: 12,
              child: Text(
                news.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: textDirection,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
