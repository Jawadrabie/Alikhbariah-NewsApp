import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

String _requiredLabel(String labelText, bool isRequired) {
  return isRequired ? '$labelText *' : labelText;
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String labelText,
  String? hintText,
  bool alignLabelWithHint = false,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  final scheme = Theme.of(context).colorScheme;

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    alignLabelWithHint: alignLabelWithHint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: scheme.onSurface.withValues(alpha: 0.04),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: scheme.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final bool isRequired;
  final bool readOnly;
  final bool alignLabelWithHint;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.isRequired = false,
    this.readOnly = false,
    this.alignLabelWithHint = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: _fieldDecoration(
          context,
          labelText: _requiredLabel(labelText, isRequired),
          hintText: hintText,
          alignLabelWithHint: alignLabelWithHint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
        validator:
            validator ??
            (isRequired
                ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                }
                : null),
        onSaved: onSaved,
        onChanged: onChanged,
      ),
    );
  }
}

class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final String labelText;
  final Widget? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final TextEditingController? searchController;
  final String? searchHintText;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.labelText,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
    this.searchController,
    this.searchHintText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField2<T>(
        value: value,
        isExpanded: true,
        decoration: _fieldDecoration(
          context,
          labelText: _requiredLabel(labelText, isRequired),
          prefixIcon: prefixIcon,
        ),
        items: items,
        onChanged: onChanged,
        validator:
            validator ??
            (isRequired
                ? (val) => val == null ? 'يرجى اختيار قيمة' : null
                : null),
        iconStyleData: IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: scheme.primary),
          iconSize: 22,
        ),
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.zero,
          height: 56,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          // Keep the popup under the field for clearer UX.
          offset: const Offset(0, 8),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: const WidgetStatePropertyAll(true),
            thickness: const WidgetStatePropertyAll(6),
            radius: const Radius.circular(12),
            thumbColor: WidgetStatePropertyAll(
              scheme.primary.withValues(alpha: 0.45),
            ),
          ),
        ),
        dropdownSearchData:
            searchController == null
                ? null
                : DropdownSearchData(
                  searchController: searchController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: searchHintText,
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return item.child
                        .toString()
                        .toLowerCase()
                        .contains(searchValue.toLowerCase());
                  },
                ),
        menuItemStyleData: const MenuItemStyleData(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

class CustomSwitchTile extends StatelessWidget {
  final bool value;
  final String title;
  final String? subtitle;
  final void Function(bool) onChanged;

  const CustomSwitchTile({
    super.key,
    required this.value,
    required this.title,
    this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          value: value,
          onChanged: onChanged,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          activeColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
