import 'package:flutter/material.dart';

part 'custom_form_field_decoration.dart';
part 'custom_form_field_dropdown.dart';

class CustomTextField extends StatelessWidget {
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
    this.showLabelAboveField = false,
    this.autovalidateMode,
  });

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
  final bool showLabelAboveField;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = _requiredLabel(labelText, isRequired);
    final field = TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: _fieldDecoration(
        context,
        labelText: showLabelAboveField ? '' : effectiveLabel,
        hintText: hintText,
        alignLabelWithHint: alignLabelWithHint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ).copyWith(
        labelText: showLabelAboveField ? null : effectiveLabel,
        floatingLabelBehavior:
            showLabelAboveField ? FloatingLabelBehavior.never : null,
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
      autovalidateMode: autovalidateMode,
      onSaved: onSaved,
      onChanged: onChanged,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child:
          showLabelAboveField
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    effectiveLabel,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  field,
                ],
              )
              : field,
    );
  }
}

class CustomSwitchTile extends StatelessWidget {
  const CustomSwitchTile({
    super.key,
    required this.value,
    required this.title,
    this.subtitle,
    required this.onChanged,
  });

  final bool value;
  final String title;
  final String? subtitle;
  final void Function(bool) onChanged;

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
