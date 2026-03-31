import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
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
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    if (categories.isEmpty) {
      return SizedBox(
        height: 52,
        child: Center(child: Text(l10n.noCategoriesAvailable)),
      );
    }

    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return ChoiceChip(
              selected: isSelected,
              label: Text(l10n.allCategories),
              onSelected:
                  onCategorySelected == null
                      ? null
                      : (_) => onCategorySelected!(null),
              selectedColor: scheme.primaryContainer,
              backgroundColor: scheme.surface,
              side: BorderSide(
                color:
                    isSelected
                        ? scheme.primary
                        : scheme.outlineVariant,
              ),
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurface,
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;

          return ChoiceChip(
            selected: isSelected,
            label: Text(category.name),
            onSelected:
                onCategorySelected == null
                    ? null
                    : (_) => onCategorySelected!(category.id),
            selectedColor: scheme.primaryContainer,
            backgroundColor: scheme.surface,
            side: BorderSide(
              color:
                  isSelected
                      ? scheme.primary
                      : scheme.outlineVariant,
            ),
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color:
                  isSelected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length + 1,
      ),
    );
  }
}
