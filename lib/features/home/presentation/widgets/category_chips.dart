import 'package:flutter/material.dart';

import '../../data/models/category_model.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key, required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 52,
        child: Center(child: Text('لا توجد تصنيفات')),
      );
    }

    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Chip(
            label: Text(category.name),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFD7DEE3)),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}
