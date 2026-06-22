import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/metric_card.dart';
import '../../services/mock_data_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();

    return AnimatedBuilder(
      animation: state,
      builder: (context, child) {
        // Calculate dynamic dashboard statistics
        final totalEmployees = state.employees.length;
        final activeEmployees = state.employees.where((e) => e.status == 'Active').length;
        
        final wonLeadsValue = state.leads
            .where((l) => l.status == 'Won')
            .fold<double>(0, (sum, l) => sum + l.value);
            
        final pipelineValue = state.leads
            .where((l) => l.status == 'New' || l.status == 'Contacted' || l.status == 'Proposal')
            .fold<double>(0, (sum, l) => sum + l.value);

        final pendingTasks = state.tasks.where((t) => t.status != 'Done').length;

        // Custom Layout Grid based on width
        final width = MediaQuery.of(context).size.width;
        final crossAxisCount = width < 600 ? 1 : (width < 1200 ? 2 : 4);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back, ${state.currentUser?.name ?? 'User'}",
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Here's what is happening with your workforce and sales pipelines today.",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // KPI Stats Grid
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: width < 600 ? 2.2 : 1.6,
                ),
                children: [
                  MetricCard(
                    title: "Total Revenue (Won)",
                    value: "\$${wonLeadsValue.toStringAsFixed(0)}",
                    changeText: "+14.2%",
                    isPositive: true,
                    icon: Icons.monetization_on_outlined,
                  ),
                  MetricCard(
                    title: "Pipeline Potential",
                    value: "\$${pipelineValue.toStringAsFixed(0)}",
                    changeText: "+8.5%",
                    isPositive: true,
                    icon: Icons.trending_up,
                    iconBgColor: const Color(0xFFEFF6FF),
                    iconColor: AppColors.info,
                  ),
                  MetricCard(
                    title: "Active Workforce",
                    value: "$activeEmployees / $totalEmployees",
                    changeText: "100% Active",
                    isPositive: true,
                    icon: Icons.people_outline,
                    iconBgColor: const Color(0xFFFEF3C7),
                    iconColor: AppColors.warning,
                  ),
                  MetricCard(
                    title: "Active Assignments",
                    value: "$pendingTasks Open",
                    changeText: "-12.5%",
                    isPositive: true,
                    icon: Icons.assignment_outlined,
                    iconBgColor: const Color(0xFFFEE2E2),
                    iconColor: AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Charts and Lists Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Sales Analytics Chart (Web: 2/3 width, Mobile: 100% width)
                  Expanded(
                    flex: width < 1000 ? 1 : 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildChartCard("Sales Revenue Progression", const _RevenueCurveChart()),
                        const SizedBox(height: 24),
                        _buildChartCard("Leads Funnel Stage Breakdown", const _LeadBarChart()),
                      ],
                    ),
                  ),

                  // Recent Activities Feed (Visible only on larger viewports)
                  if (width >= 1000) ...[
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 600,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "System Notifications Log",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: state.notifications.length,
                                itemBuilder: (context, index) {
                                  final item = state.notifications[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: item.isRead ? Colors.grey[300] : AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.message,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')} today",
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartCard(String title, Widget chartWidget) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: chartWidget,
          ),
        ],
      ),
    );
  }
}

// Custom Vector Line Chart
class _RevenueCurveChart extends StatelessWidget {
  const _RevenueCurveChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.2),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paintGrid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Draw Grid Lines (Horizontal)
    final gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = size.height * i / gridCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // Points of the Revenue Wave
    final points = [
      Offset(size.width * 0.0, size.height * 0.75),
      Offset(size.width * 0.2, size.height * 0.60),
      Offset(size.width * 0.4, size.height * 0.85),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.45),
      Offset(size.width * 1.0, size.height * 0.15),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
      );
    }

    // Gradient fill path
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Draw point nodes
    final paintDots = Paint()..color = AppColors.primary;
    final paintWhite = Paint()..color = Colors.white;
    for (final pt in points) {
      canvas.drawCircle(pt, 5, paintDots);
      canvas.drawCircle(pt, 2.5, paintWhite);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Lead Pipeline Stage Bar Chart
class _LeadBarChart extends StatelessWidget {
  const _LeadBarChart();

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final stages = ['New', 'Contacted', 'Proposal', 'Won', 'Lost'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: stages.map((stage) {
        final count = state.leads.where((l) => l.status == stage).length;
        // Find max count to scale
        final maxCount = state.leads.length;
        final pct = maxCount > 0 ? (count / maxCount) : 0.0;
        final barHeight = 140 * pct;

        Color barColor;
        switch (stage) {
          case 'New':
            barColor = Colors.blue;
            break;
          case 'Contacted':
            barColor = Colors.orange;
            break;
          case 'Proposal':
            barColor = Colors.purple;
            break;
          case 'Won':
            barColor = AppColors.success;
            break;
          default:
            barColor = AppColors.danger;
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "$count",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: barHeight < 10 ? 10 : barHeight,
              decoration: BoxDecoration(
                color: barColor.withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stage,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
