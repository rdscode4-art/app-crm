import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = isSecondary ? Colors.white : AppColors.primary;
    final textColor = isSecondary ? AppColors.textPrimary : Colors.white;
    final borderSide = isSecondary
        ? const BorderSide(color: AppColors.border, width: 1.5)
        : BorderSide.none;

    final childWidget = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(MaterialState.hovered)) {
                return isSecondary
                    ? Colors.grey.withOpacity(0.05)
                    : Colors.white.withOpacity(0.1);
              }
              if (states.contains(MaterialState.pressed)) {
                return isSecondary
                    ? Colors.grey.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2);
              }
              return null;
            },
          ),
        ),
        onPressed: onPressed,
        child: childWidget,
      ),
    );
  }
}
