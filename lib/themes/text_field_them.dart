import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldThem {
  const TextFieldThem({Key? key});

  static InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.hintColor,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: theme.inputDecorationTheme.border?.borderSide ??
            BorderSide(
              color: theme.dividerColor,
              width: 1,
            ),
      ),
      focusedBorder: theme.inputDecorationTheme.focusedBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.primaryColor,
              width: 1.5,
            ),
          ),
      enabledBorder: theme.inputDecorationTheme.enabledBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  static Widget buildTextField(
      BuildContext context, {
        required String hintText,
        required TextEditingController controller,
        TextInputType keyBoardType = TextInputType.text,
        bool enable = true,
        int maxLines = 1,
      }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyBoardType,
      maxLines: maxLines,
      enabled: enable,
      style: theme.textTheme.bodyLarge,
      decoration: _buildInputDecoration(context: context, hintText: hintText),
    );
  }

  static Widget buildTextFieldWithPrefixIcon(
      BuildContext context, {
        required String hintText,
        required TextEditingController controller,
        required Widget prefixIcon,
        TextInputType keyBoardType = TextInputType.text,
        bool enable = true,
        ValueChanged<String>? onChanged,
      }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyBoardType,
      enabled: enable,
      onChanged: onChanged,
      style: theme.textTheme.bodyLarge,
      decoration: _buildInputDecoration(
        context: context,
        hintText: hintText,
        prefixIcon: prefixIcon,
      ),
    );
  }

  static Widget buildTextFieldWithSuffixIcon(
      BuildContext context, {
        required String hintText,
        required TextEditingController controller,
        required Widget suffixIcon,
        TextInputType keyBoardType = TextInputType.text,
        bool enable = true,
      }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyBoardType,
      enabled: enable,
      style: theme.textTheme.bodyLarge,
      decoration: _buildInputDecoration(
        context: context,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }

  static Widget buildMaskedTextField(
      BuildContext context, {
        required String hintText,
        required TextEditingController controller,
        required TextInputFormatter inputMaskFormatter,
        TextInputType keyBoardType = TextInputType.text,
        bool enable = true,
        int maxLines = 1,
      }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyBoardType,
      maxLines: maxLines,
      enabled: enable,
      inputFormatters: [inputMaskFormatter],
      style: theme.textTheme.bodyLarge,
      decoration: _buildInputDecoration(context: context, hintText: hintText),
    );
  }
}
