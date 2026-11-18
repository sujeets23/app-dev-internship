import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clean, validated text field with label and counter
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          autofocus: autofocus,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}
