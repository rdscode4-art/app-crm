import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String changeText;
  final bool isPositive;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.changeText,
    required this.isPositive,
    required this.icon,
    this.iconBgColor = const Color(0xFFECFDF5),
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 600;

    final double cardPadding = isCompact ? 12.0 : 20.0;
    final double titleFontSize = isCompact ? 12.0 : 14.0;
    final double valueFontSize = isCompact ? 20.0 : 24.0;
    final double trendFontSize = isCompact ? 9.5 : 12.0;
    final double iconSize = isCompact ? 16.0 : 20.0;
    final double iconPadding = isCompact ? 6.0 : 8.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: trendFontSize + 2,
                color: isPositive ? AppColors.success : AppColors.danger,
              ),
              Text(
                changeText,
                style: TextStyle(
                  color: isPositive ? AppColors.success : AppColors.danger,
                  fontSize: trendFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "vs last month",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: trendFontSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
