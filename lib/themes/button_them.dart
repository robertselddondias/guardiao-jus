import 'package:flutter/material.dart';
import 'package:guardiao_cliente/themes/responsive.dart';

class ButtonThem {
  const ButtonThem({Key? key});

  // Botão sólido
  static Widget buildButton(
      BuildContext context, {
        required String title,
        double btnHeight = 48,
        double txtSize = 14,
        double btnWidthRatio = 0.9,
        double btnRadius = 10,
        required VoidCallback onPress,
        bool isVisible = true,
      }) {
    final theme = Theme.of(context); // Obtem tema

    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: Responsive.width(100, context) * btnWidthRatio,
        child: ElevatedButton(
          onPressed: onPress,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(btnRadius),
            ),
            padding: EdgeInsets.symmetric(vertical: btnHeight / 3),
          ),
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: txtSize,
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Botão com borda
  static Widget buildBorderButton(
      BuildContext context, {
        required String title,
        double btnHeight = 50,
        double txtSize = 14,
        double btnWidthRatio = 0.9,
        double borderRadius = 10,
        required VoidCallback onPress,
        bool isVisible = true,
        bool iconVisibility = false,
        String iconAssetImage = '',
      }) {
    final theme = Theme.of(context); // Obtem tema

    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: Responsive.width(100, context) * btnWidthRatio,
        height: btnHeight,
        child: OutlinedButton(
          onPressed: onPress,
          style: OutlinedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            side: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: EdgeInsets.symmetric(vertical: btnHeight / 4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconVisibility)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    iconAssetImage,
                    fit: BoxFit.cover,
                    width: 24,
                    height: 24,
                  ),
                ),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: txtSize,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Botão arredondado
  static Widget roundButton(
      BuildContext context, {
        required String title,
        double btnHeight = 48,
        double txtSize = 14,
        double btnWidthRatio = 0.9,
        required VoidCallback onPress,
        bool isVisible = true,
      }) {
    final theme = Theme.of(context); // Obtem tema

    return Visibility(
      visible: isVisible,
      child: SizedBox(
        width: Responsive.width(100, context) * btnWidthRatio,
        child: ElevatedButton(
          onPressed: onPress,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: btnHeight / 3),
          ),
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: txtSize,
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
