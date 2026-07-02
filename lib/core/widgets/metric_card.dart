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
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16), // Softer, more modern corners
              border: Border.all(
                color: _isHovered ? widget.iconColor.withOpacity(0.3) : AppColors.border,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered 
                      ? widget.iconColor.withOpacity(0.1) 
                      : Colors.black.withOpacity(0.02),
                  blurRadius: _isHovered ? 16 : 10,
                  offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
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
                        widget.title,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        color: _isHovered ? widget.iconBgColor.withOpacity(0.8) : widget.iconBgColor,
                        shape: BoxShape.circle,
                        boxShadow: _isHovered ? [
                          BoxShadow(
                            color: widget.iconColor.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ] : [],
                      ),
                      child: Icon(
                        widget.icon,
                        size: iconSize,
                        color: widget.iconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.value,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: valueFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 2,
                            children: [
                              Icon(
                                widget.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                                size: trendFontSize + 2,
                                color: widget.isPositive ? AppColors.success : AppColors.danger,
                              ),
                              Text(
                                widget.changeText,
                                style: TextStyle(
                                  color: widget.isPositive ? AppColors.success : AppColors.danger,
                                  fontSize: trendFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Sparkline
                    Container(
                      width: isCompact ? 40 : 55,
                      height: isCompact ? 20 : 28,
                      margin: const EdgeInsets.only(bottom: 2),
                      child: CustomPaint(
                        painter: _SparklinePainter(
                          data: widget.trendData ?? 
                              (widget.isPositive 
                                  ? [10, 15, 13, 20, 18, 25] 
                                  : [25, 20, 22, 14, 16, 10]),
                          lineColor: widget.isPositive ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ),
                  ],
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
          lineColor.withOpacity(0.18),
          lineColor.withOpacity(0.0),
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
      final y = size.height - ((data[i] - minVal) / range) * (size.height - 4) - 2;
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
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
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
