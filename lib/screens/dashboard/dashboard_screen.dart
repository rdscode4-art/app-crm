import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/metric_card.dart';
import '../../services/mock_data_service.dart';
import '../../core/widgets/custom_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();

    return Obx(() {
      switch (state.currentRole) {
        case UserRole.superAdmin:
          return _buildSuperAdminDashboard(context, state);
        case UserRole.hr:
          return _buildHRDashboard(context, state);
        case UserRole.employee:
          return _buildEmployeeDashboard(context, state);
      }
    });
  }

  // --- Super Admin Dashboard ---
  Widget _buildSuperAdminDashboard(BuildContext context, MockDataService state) {
    final totalEmployees = state.employees.length;
    final activeEmployees = state.employees.where((e) => e.status == 'Active').length;
    
    final wonLeadsValue = state.leads
        .where((l) => l.status == 'Won')
        .fold<double>(0, (sum, l) => sum + l.value);
        
    final pipelineValue = state.leads
        .where((l) => l.status == 'New' || l.status == 'Contacted' || l.status == 'Proposal')
        .fold<double>(0, (sum, l) => sum + l.value);

    final pendingTasks = state.tasks.where((t) => t.status != 'Done').length;

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
              childAspectRatio: width < 600 ? 2.0 : 1.6,
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
              // Main Sales Analytics Chart
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

              // Recent Activities Feed
              if (width >= 1000) ...[
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildSystemNotificationsLog(context, state),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- HR Dashboard ---
  Widget _buildHRDashboard(BuildContext context, MockDataService state) {
    final totalEmployees = state.employees.length;
    final activeEmployees = state.employees.where((e) => e.status == 'Active').length;
    final pendingLeaves = state.leaveRequests.where((l) => l.status.toLowerCase() == 'pending').length;
    final assignedAssets = state.assets.where((a) => a.status == 'Assigned').length;
    final reportsCount = state.dailyReports.length;

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : 4;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back, ${state.currentUser?.name ?? 'HR Manager'}",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "HR Control Center: Monitor personnel, approve leave requests, and track company assets.",
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

          // KPI Stats
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: width < 600 ? 1.25 : 2.0,
            ),
            children: [
              MetricCard(
                title: "Active Personnel",
                value: "$activeEmployees / $totalEmployees",
                changeText: "100% Active",
                isPositive: true,
                icon: Icons.people_outline,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: AppColors.info,
              ),
              MetricCard(
                title: "Leaves Pending",
                value: "$pendingLeaves",
                changeText: "Requires review",
                isPositive: false,
                icon: Icons.beach_access_outlined,
                iconBgColor: const Color(0xFFFEE2E2),
                iconColor: AppColors.danger,
              ),
              MetricCard(
                title: "Assigned Assets",
                value: "$assignedAssets Devices",
                changeText: "Allocated",
                isPositive: true,
                icon: Icons.devices_other_outlined,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: AppColors.warning,
              ),
              MetricCard(
                title: "Reports Filed",
                value: "$reportsCount Logs",
                changeText: "Work logs",
                isPositive: true,
                icon: Icons.note_alt_outlined,
                iconBgColor: const Color(0xFFD1FAE5),
                iconColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Lists & Activity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: width < 1000 ? 1 : 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pending Leave Approval Queue",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          state.leaveRequests.where((l) => l.status.toLowerCase() == 'pending').isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(
                                      "No pending leave requests.",
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state.leaveRequests.where((l) => l.status.toLowerCase() == 'pending').length,
                                  separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                                  itemBuilder: (context, index) {
                                    final req = state.leaveRequests.where((l) => l.status.toLowerCase() == 'pending').toList()[index];
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                req.employeeName,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                "${req.type} | ${req.reason}",
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                                              onPressed: () {
                                                state.updateLeaveStatus(req.id, 'Approved');
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                                              onPressed: () {
                                                state.updateLeaveStatus(req.id, 'Rejected');
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hardware Asset Overview",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.assets.take(3).length,
                            separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                            itemBuilder: (context, index) {
                              final asset = state.assets[index];
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    asset.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    asset.assignedTo,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (width >= 1000) ...[
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildSystemNotificationsLog(context, state),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- Employee Dashboard ---
  Widget _buildEmployeeDashboard(BuildContext context, MockDataService state) {
    final userId = state.currentUser?.id ?? '';
    final myTasks = state.tasks.where((t) => t.assignedTo == state.currentUser?.name && t.status != 'Done').toList();
    final myLeaves = state.leaveRequests.where((l) => l.employeeId == userId).toList();
    final myLeavesCount = myLeaves.length;
    
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : 4;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back, ${state.currentUser?.name ?? 'Employee'}",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Employee Portal: View active tasks, submit leaves, and track daily attendance shifts.",
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

          // KPI Stats
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: width < 600 ? 1.25 : 2.0,
            ),
            children: [
              MetricCard(
                title: "My Open Tasks",
                value: "${myTasks.length} Assigned",
                changeText: "Active tasks",
                isPositive: true,
                icon: Icons.task_alt_outlined,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: AppColors.info,
              ),
              MetricCard(
                title: "Leave Requests",
                value: "$myLeavesCount Submitted",
                changeText: "Approved: ${myLeaves.where((l) => l.status == 'Approved').length}",
                isPositive: true,
                icon: Icons.beach_access_outlined,
                iconBgColor: const Color(0xFFD1FAE5),
                iconColor: AppColors.primary,
              ),
              MetricCard(
                title: "Punch Status",
                value: state.isPunchedIn ? "Punched In" : "Punched Out",
                changeText: state.todayAttendance != null ? "Started at ${state.todayAttendance!.checkInTime}" : "Not clocked-in today",
                isPositive: state.isPunchedIn,
                icon: Icons.fingerprint,
                iconBgColor: state.isPunchedIn ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                iconColor: state.isPunchedIn ? AppColors.primary : AppColors.danger,
              ),
              MetricCard(
                title: "Performance KPI",
                value: "${state.currentUser?.performanceRating ?? 'N/A'}",
                changeText: "Rating star",
                isPositive: true,
                icon: Icons.insights_outlined,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: width < 1000 ? 1 : 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardAttendanceCard(state: state),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "My Assigned Tasks",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          myTasks.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(
                                      "Great job! You have no pending tasks.",
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: myTasks.length,
                                  separatorBuilder: (context, index) => const Divider(color: AppColors.border),
                                  itemBuilder: (context, index) {
                                    final task = myTasks[index];
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.title,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                task.description,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                                          onPressed: () {
                                            state.updateTaskStatus(task.id, 'Done');
                                            state.addNotification("Task Completed", "You marked task '${task.title}' as done!");
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (width >= 1000) ...[
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildSystemNotificationsLog(context, state),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildSystemNotificationsLog(BuildContext context, MockDataService state) {
    return Container(
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
              style: const TextStyle(
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

class _DashboardAttendanceCard extends StatefulWidget {
  final MockDataService state;
  const _DashboardAttendanceCard({super.key, required this.state});

  @override
  State<_DashboardAttendanceCard> createState() => _DashboardAttendanceCardState();
}

class _DashboardAttendanceCardState extends State<_DashboardAttendanceCard> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _DashboardAttendanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.state.isPunchedIn) {
      _calculateElapsed();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _calculateElapsed();
          });
        }
      });
    } else {
      _elapsed = Duration.zero;
    }
  }

  void _calculateElapsed() {
    final att = widget.state.todayAttendance;
    if (att != null && att.checkInTime != '--:--') {
      try {
        final parts = att.checkInTime.split(':');
        final hour = int.parse(parts[0]);
        final min = int.parse(parts[1]);
        final now = DateTime.now();
        final checkInDateTime = DateTime(now.year, now.month, now.day, hour, min);
        final diff = now.difference(checkInDateTime);
        if (diff.isNegative) {
          _elapsed = Duration.zero;
        } else {
          _elapsed = diff;
        }
      } catch (_) {
        _elapsed = Duration.zero;
      }
    } else {
      _elapsed = Duration.zero;
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final isPunched = widget.state.isPunchedIn;
    final isMobile = MediaQuery.of(context).size.width < 600;

    final infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isPunched ? "Active Work Shift" : "Shift Attendance",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (isPunched) ...[
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Working Hours: ${_formatDuration(_elapsed)}",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Checked in at ${widget.state.todayAttendance?.checkInTime ?? ''}",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ] else ...[
          const Text(
            "You are not clocked in for work today yet.",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );

    final actionButton = CustomButton(
      text: isPunched ? "Check Out" : "Check In",
      icon: isPunched ? Icons.logout : Icons.login,
      backgroundColor: isPunched ? AppColors.danger : AppColors.primary,
      width: isMobile ? double.infinity : null,
      onPressed: () {
        if (isPunched) {
          widget.state.punchOut();
        } else {
          widget.state.punchIn();
        }
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _startTimer();
        });
      },
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                infoColumn,
                const SizedBox(height: 16),
                actionButton,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: infoColumn),
                const SizedBox(width: 16),
                actionButton,
              ],
            ),
    );
  }
}
