part of 'custom_form_fields.dart';

class CustomDropdownField<T> extends StatefulWidget {
  const CustomDropdownField({
    super.key,
    required this.value,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    this.enableSearch = true,
    this.width,
    this.isDense = false,
  });

  final T? value;
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final bool enableSearch;
  final double? width;
  final bool isDense;

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  T? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant CustomDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final localeCode = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    final effectiveHint =
        widget.hintText ??
      (localeCode == 'ar'
            ? 'اضغط للاختيار'
            : 'Tap to select');
    final outerPadding =
        widget.isDense
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: 8);

    return SizedBox(
      width: widget.width,
      child: Padding(
        padding: outerPadding,
        child: FormField<T>(
          initialValue: _currentValue,
          validator:
              widget.validator ??
              (widget.isRequired
                  ? (val) => val == null ? 'يرجى اختيار قيمة' : null
                  : null),
          builder: (fieldState) {
            final currentItem =
                widget.items
                    .where((item) => item.value == fieldState.value)
                    .firstOrNull;
            final currentLabel = _itemLabel(currentItem?.child);
            final hasSelection =
                currentItem != null && currentLabel.trim().isNotEmpty;
            final displayText = hasSelection ? currentLabel : effectiveHint;
            final displayColor =
                hasSelection
                    ? scheme.onSurface
                    : scheme.onSurface.withValues(alpha: 0.62);
            final borderColor =
                fieldState.hasError
                ? scheme.error
                : Colors.transparent;
            final radius = BorderRadius.circular(10);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _requiredLabel(widget.labelText, widget.isRequired),
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: radius,
                    onTap:
                        widget.onChanged == null
                            ? null
                            : () async {
                              final selectedResult =
                                  await _showSelectionDialog<T>(
                                    context,
                                    widget.labelText,
                                    widget.items,
                                    fieldState.value,
                                    widget.enableSearch,
                                  );
                              if (!mounted) return;
                              if (selectedResult == null ||
                                  !selectedResult.didSelect) {
                                return;
                              }
                              final selected = selectedResult.value;
                              if (selected == fieldState.value) {
                                return;
                              }
                              fieldState.didChange(selected);
                              setState(() {
                                _currentValue = selected;
                              });
                              widget.onChanged?.call(selected);
                            },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: widget.isDense ? 14 : 16,
                      ),
                      constraints: BoxConstraints(
                        minHeight: widget.isDense ? 52 : 56,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.onSurface.withValues(alpha: 0.04),
                        borderRadius: radius,
                        border: Border.all(color: borderColor, width: 1.15),
                      ),
                      child: Row(
                        children: [
                          if (widget.prefixIcon != null) ...[
                            IconTheme(
                              data: IconThemeData(
                                color: scheme.primary,
                                size: 20,
                              ),
                              child: widget.prefixIcon!,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Text(
                              displayText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: displayColor,
                                fontWeight:
                                    hasSelection
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: scheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (fieldState.hasError) ...[
                  const SizedBox(height: 6),
                  Text(
                    fieldState.errorText ?? '',
                    style: TextStyle(
                      color: scheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _itemLabel(Widget? child) {
    if (child is Text) {
      if (child.data != null) {
        return child.data!.trim();
      }
      if (child.textSpan != null) {
        return child.textSpan!.toPlainText().trim();
      }
    }
    return child?.toStringShort() ?? '';
  }
}

class _DropdownSelectionResult<T> {
  const _DropdownSelectionResult({
    required this.didSelect,
    required this.value,
  });

  final bool didSelect;
  final T? value;
}

Future<_DropdownSelectionResult<T>?> _showSelectionDialog<T>(
  BuildContext context,
  String title,
  List<DropdownMenuItem<T>> items,
  T? selectedValue,
  bool enableSearch,
) async {
  final searchController = TextEditingController();
  final listScrollController = ScrollController();
  final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
  // Keep search for larger datasets only; short lists are faster to scan directly.
  final effectiveEnableSearch = enableSearch && items.length > 6;
  var query = '';

  try {
    return await showDialog<_DropdownSelectionResult<T>>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;

        return StatefulBuilder(
          builder: (dialogBodyContext, setLocalState) {
            final filteredItems =
                !effectiveEnableSearch || query.isEmpty
                    ? items
                    : items.where((item) {
                      final label = _dialogItemLabel(item.child).toLowerCase();
                      return label.contains(query.toLowerCase());
                    }).toList();
            final screenHeight = MediaQuery.of(dialogContext).size.height;
            final maxListHeight = screenHeight * 0.52;
            final visibleCount =
                filteredItems.isEmpty
                    ? 1
                    : filteredItems.length.clamp(1, 7).toInt();
            final estimatedListHeight =
                filteredItems.isEmpty
                    ? 96.0
                    : visibleCount * 58.0 + (visibleCount - 1) * 6.0 + 24.0;
            final listHeight =
                estimatedListHeight.clamp(96.0, maxListHeight).toDouble();

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: scheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.22),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: scheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(dialogContext).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          IconButton(
                            tooltip: locale == 'ar' ? 'إغلاق' : 'Close',
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    if (effectiveEnableSearch)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                        child: TextField(
                          controller: searchController,
                          onChanged:
                              (value) =>
                                  setLocalState(() => query = value.trim()),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            hintText:
                                locale == 'ar'
                                    ? 'ابحث داخل الخيارات'
                                    : 'Search options',
                            filled: true,
                            fillColor: scheme.surfaceContainerLowest,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: scheme.outlineVariant,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: scheme.outlineVariant,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: scheme.primary,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Divider(
                      height: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      height: listHeight,
                      child:
                          filteredItems.isEmpty
                              ? Center(
                                child: Text(
                                  locale == 'ar'
                                      ? 'لا توجد نتائج مطابقة'
                                      : 'No matching results',
                                  style: Theme.of(
                                    dialogContext,
                                  ).textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              : Scrollbar(
                                controller: listScrollController,
                                thumbVisibility: true,
                                child: ListView.separated(
                                  controller: listScrollController,
                                  padding: const EdgeInsets.all(12),
                                  itemCount: filteredItems.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 6),
                                  itemBuilder: (dialogBodyContext, index) {
                                    final item = filteredItems[index];
                                    final isSelected =
                                        item.value == selectedValue;

                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          Navigator.of(dialogContext).pop(
                                            _DropdownSelectionResult<T>(
                                              didSelect: true,
                                              value: item.value,
                                            ),
                                          );
                                        },
                                        child: Ink(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? scheme.primary.withValues(
                                                      alpha: 0.12,
                                                    )
                                                    : scheme
                                                        .surfaceContainerLowest,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? scheme.primary.withValues(
                                                        alpha: 0.45,
                                                      )
                                                      : scheme.outlineVariant
                                                          .withValues(
                                                            alpha: 0.65,
                                                          ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(child: item.child),
                                              const SizedBox(width: 10),
                                              AnimatedOpacity(
                                                opacity: isSelected ? 1 : 0,
                                                duration: const Duration(
                                                  milliseconds: 120,
                                                ),
                                                child: Icon(
                                                  Icons.check_circle_rounded,
                                                  color: scheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  } finally {
    searchController.dispose();
    listScrollController.dispose();
  }
}

String _dialogItemLabel(Widget? child) {
  if (child is Text) {
    if (child.data != null) {
      return child.data!.trim();
    }
    if (child.textSpan != null) {
      return child.textSpan!.toPlainText().trim();
    }
  }
  return child?.toStringShort() ?? '';
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
