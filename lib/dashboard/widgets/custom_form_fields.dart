import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final int maxLines;
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
        decoration: InputDecoration(
          labelText: isRequired ? '$labelText *' : labelText,
          hintText: hintText,
          alignLabelWithHint: alignLabelWithHint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator ?? (isRequired
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

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.labelText,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: isRequired ? '$labelText *' : labelText,
          prefixIcon: prefixIcon,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items,
        onChanged: onChanged,
        validator: validator ?? (isRequired
            ? (val) => val == null ? 'يرجى اختيار قيمة' : null
            : null),
        dropdownColor: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          value: value,
          onChanged: onChanged,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          activeColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
