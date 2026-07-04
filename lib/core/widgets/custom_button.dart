import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height = 48,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        backgroundColor ?? (isSecondary ? Colors.white : AppColors.primary);
    final buttonTextColor =
        textColor ?? (isSecondary ? AppColors.textPrimary : Colors.white);
    final borderSide = isSecondary
        ? const BorderSide(color: AppColors.border, width: 1.5)
        : BorderSide.none;

    final childWidget = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: buttonTextColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: buttonTextColor,
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
        style:
            ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: borderSide,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.hovered)) {
                  return isSecondary
                      ? Colors.grey.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.pressed)) {
                  return isSecondary
                      ? Colors.grey.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.2);
                }
                return null;
              }),
            ),
        onPressed: isLoading ? null : onPressed,
        child: childWidget,
      ),
    );
  }
}
