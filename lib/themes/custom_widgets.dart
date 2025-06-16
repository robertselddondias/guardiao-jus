import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';

class CustomWidgets {
  // Campo de texto customizado
  static Widget buildTextField({
    required BuildContext context, // Contexto obrigatório
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLine,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    int? maxLenght
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLenght,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      maxLines: maxLine ?? 1,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: _outlineBorder(context),
        enabledBorder: _outlineBorder(context, opacity: 0.6),
        focusedBorder: _outlineBorder(context, width: 1.8),
        counterText: ''
      ),
    );
  }

  // Campo de texto com máscara
  static Widget buildTextFieldMask({
    required BuildContext context, // Contexto obrigatório
    required String label,
    required TextEditingController controller,
    required TextInputFormatter mask,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [mask],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: _outlineBorder(context),
        enabledBorder: _outlineBorder(context, opacity: 0.6),
        focusedBorder: _outlineBorder(context, width: 1.8),
      ),
    );
  }

  // Campo de data customizado
  static Widget buildDateField({
    required BuildContext context, // Contexto obrigatório
    required String label,
    required TextEditingController controller,

  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: _outlineBorder(context),
        enabledBorder: _outlineBorder(context, opacity: 0.6),
        focusedBorder: _outlineBorder(context, width: 1.8),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.text = DateUtilsCustom.formatDate(pickedDate.toIso8601String());
        }
      },
    );
  }

  // Botão customizado
  static Widget buildButton({
    required BuildContext context, // Contexto obrigatório
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    double borderRadius = 12.0,
    double height = 50.0,
    double width = double.infinity,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20, color: textColor ?? Colors.white) : const SizedBox.shrink(),
        label: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor ?? Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 4,
          shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.1);
            }
            return null;
          }),
        ),
      ),
    );
  }

  // Borda personalizada para campos
  static OutlineInputBorder _outlineBorder(BuildContext context, {double width = 1.0, double opacity = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(opacity),
        width: width,
      ),
    );
  }
}
