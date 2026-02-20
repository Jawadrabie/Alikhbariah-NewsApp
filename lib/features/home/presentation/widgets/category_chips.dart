import 'package:flutter/material.dart';

import '../../data/models/category_model.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?>? onCategorySelected;

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
          final isSelected = selectedCategoryId == category.id;

          return ChoiceChip(
            selected: isSelected,
            label: Text(category.name),
            onSelected: onCategorySelected == null
                ? null
                : (_) => onCategorySelected!(category.id),
            selectedColor: Theme.of(context).colorScheme.primary.withAlpha(35),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFFD7DEE3),
            ),
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFF1F2937),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}
