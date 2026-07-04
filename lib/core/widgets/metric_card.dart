import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MetricCard extends StatefulWidget {
  final String title;
  final String value;
  final String changeText;
  final bool isPositive;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final List<double>? trendData;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.changeText,
    required this.isPositive,
    required this.icon,
    this.iconBgColor = const Color(0xFFECFDF5),
    this.iconColor = AppColors.primary,
    this.trendData,
    this.onTap,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 600;

    final double cardPadding = isCompact ? 16.0 : 20.0;
    final double titleFontSize = isCompact ? 14.0 : 16.0;
    final double valueFontSize = isCompact ? 22.0 : 28.0;
    final double trendFontSize = isCompact ? 12.0 : 14.0;
    final double iconSize = isCompact ? 24.0 : 28.0;
    final double iconPadding = isCompact ? 8.0 : 10.0;

    // Determine scale and shadow based on states
    final scale = _isPressed
        ? 0.97
        : _isHovered
        ? 1.03
        : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(
                16,
              ), // Softer, more modern corners
              border: Border.all(
                color: _isHovered
                    ? widget.iconColor.withValues(alpha: 0.3)
                    : AppColors.border,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.iconColor.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: _isHovered ? 16 : 10,
                  offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.iconColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.value,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  _SparklinePainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.18),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final stepX = size.width / (data.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      // Invert Y because canvas coordinates start from top-left
      final y =
          size.height - ((data[i] - minVal) / range) * (size.height - 4) - 2;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      // Draw smooth curve using cubic bezier
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.lineColor != lineColor;
}
