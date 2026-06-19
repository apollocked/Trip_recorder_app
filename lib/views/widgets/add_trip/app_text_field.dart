import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ColorScheme colorScheme;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final String? prefixText;
  final int? maxLength;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.colorScheme,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixText,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final formatters = <TextInputFormatter>[];
    if (keyboardType == TextInputType.number) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: formatters.isNotEmpty ? formatters : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        prefixText: prefixText,
        filled: true,
        fillColor: colorScheme.surface,
        errorStyle: const TextStyle(fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
