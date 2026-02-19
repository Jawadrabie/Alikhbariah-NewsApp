import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class NewsCardShimmer extends StatelessWidget {
  const NewsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                const ShimmerLoading(width: 150, height: 16),
                const SizedBox(height: 8),
                const ShimmerLoading(width: double.infinity, height: 12),
                const SizedBox(height: 4),
                const ShimmerLoading(width: 200, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const ShimmerLoading(width: 80, height: 80, borderRadius: 12),
        ],
      ),
    );
  }
}

class CategoryChipsShimmer extends StatelessWidget {
  const CategoryChipsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        // Use generator for multiple shimmering chips
        children: List.generate(
          5,
          (index) => const Padding(
            padding: EdgeInsets.only(left: 8),
            child: ShimmerLoading(width: 80, height: 32, borderRadius: 20),
          ),
        ),
      ),
    );
  }
}

