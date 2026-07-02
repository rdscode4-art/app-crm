import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/metric_card.dart';
import '../../services/mock_data_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../controllers/crm_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final controller = Get.find<CrmController>();

    if (controller.dashboardStats.value == null && !controller.isLoadingDashboardStats.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchDashboardStats();
      });
    }

    return Obx(() {
      if (controller.isLoadingDashboardStats.value && controller.dashboardStats.value == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.dashboardStatsError.value != null && controller.dashboardStats.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                "Error: ${controller.dashboardStatsError.value}",
                style: const TextStyle(color: AppColors.danger),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchDashboardStats(),
                child: const Text("Retry"),
              ),
            ],
          ),
        );
      }

      if (controller.dashboardStats.value != null) {
        return _buildApiStatsDashboard(context, controller.dashboardStats.value!, controller, state);
      }

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

  Widget _buildApiStatsDashboard(BuildContext context, Map<String, dynamic> stats, CrmController controller, MockDataService state) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    
    final employees = stats['employees'] ?? {};
    final attendance = stats['attendance'] ?? {};
    final leaves = stats['leaves'] ?? {};
    final tasks = stats['tasks'] ?? {};
    final leadStats = controller.leadStats.value ?? {};

    final totalEmployees = employees['total'] ?? 0;
    final activeEmployees = employees['active'] ?? 0;
    final newEmployees = employees['newThisMonth'] ?? 0;

    final todayPresent = attendance['todayPresent'] ?? 0;
    final attendanceRate = attendance['attendanceRate']?.toString() ?? '0';

    final pendingLeaves = leaves['pending'] ?? 0;
    final approvedLeaves = leaves['approvedThisMonth'] ?? 0;

    final pendingTasks = tasks['pending'] ?? 0;
    final inProgressTasks = tasks['inProgress'] ?? 0;
    final completedTasks = tasks['completed'] ?? 0;

    final recentTasks = List<Map<String, dynamic>>.from(tasks['recent'] ?? []);
    final recentEmployees = List<Map<String, dynamic>>.from(employees['recent'] ?? []);
    final byDepartment = List<Map<String, dynamic>>.from(employees['byDepartment'] ?? []);

    return RefreshIndicator(
      onRefresh: () => controller.fetchDashboardStats(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingHeaderCard(
              context: context,
              userName: "RidealCRM Overview",
              subtitle: "Real-time corporate overview: $activeEmployees / $totalEmployees personnel active today.",
              trailing: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => controller.fetchDashboardStats(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width < 600 ? 1 : (width < 1200 ? 2 : 4),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: width < 600 ? 2.0 : 1.6,
              ),
              children: [
                MetricCard(
                  title: "Active Personnel",
                  value: "$activeEmployees / $totalEmployees",
                  changeText: "+$newEmployees this month",
                  isPositive: true,
                  icon: Icons.people_outline,
                  iconBgColor: const Color(0xFFEFF6FF),
                  iconColor: AppColors.info,
                ),
                MetricCard(
                  title: "Today's Attendance",
                  value: "$todayPresent Present",
                  changeText: "$attendanceRate% attendance rate",
                  isPositive: true,
                  icon: Icons.done_all_outlined,
                  iconBgColor: const Color(0xFFD1FAE5),
                  iconColor: AppColors.primary,
                ),
                MetricCard(
                  title: "Leaves Pending",
                  value: "$pendingLeaves Request${pendingLeaves == 1 ? '' : 's'}",
                  changeText: "$approvedLeaves approved this month",
                  isPositive: false,
                  icon: Icons.beach_access_outlined,
                  iconBgColor: const Color(0xFFFEF3C7),
                  iconColor: AppColors.warning,
                ),
                MetricCard(
                  title: "Pending Tasks",
                  value: "$pendingTasks Open",
                  changeText: "$inProgressTasks in progress, $completedTasks done",
                  isPositive: true,
                  icon: Icons.assignment_outlined,
                  iconBgColor: const Color(0xFFFEE2E2),
                  iconColor: AppColors.danger,
                ),
                if (leadStats.isNotEmpty) ...[
                  MetricCard(
                    title: "Total Leads",
                    value: "${leadStats['total'] ?? 0}",
                    changeText: "${leadStats['converted'] ?? 0} converted, ${leadStats['lost'] ?? 0} lost",
                    isPositive: true,
                    icon: Icons.leaderboard_outlined,
                    iconBgColor: const Color(0xFFE0E7FF),
                    iconColor: Colors.indigo,
                  ),
                  MetricCard(
                    title: "Deal Value",
                    value: "₹${(leadStats['totalValue'] ?? 0).toStringAsFixed(0)}",
                    changeText: "Active potential revenue",
                    isPositive: true,
                    icon: Icons.currency_rupee,
                    iconBgColor: const Color(0xFFDCFCE7),
                    iconColor: Colors.green,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isDesktop ? 2 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.currentRole == UserRole.superAdmin && controller.leads.isNotEmpty) ...[
                        _buildDashboardCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Leads by Assigned Agent",
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Builder(
                                builder: (context) {
                                  final leadsByAgent = <String, int>{};
                                  for (var lead in controller.leads) {
                                    leadsByAgent[lead.owner] = (leadsByAgent[lead.owner] ?? 0) + 1;
                                  }
                                  final sortedAgents = leadsByAgent.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                                  
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: sortedAgents.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final entry = sortedAgents[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.primary.withOpacity(0.1),
                                          foregroundColor: AppColors.primary,
                                          child: Text(entry.key.isNotEmpty ? entry.key[0].toUpperCase() : '?'),
                                        ),
                                        title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "${entry.value} Leads",
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      _buildDashboardCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Upcoming Lead Follow-ups (Next 5 Days)",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (controller.isLoadingFollowups.value)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                              )
                            else if (controller.upcomingFollowups.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    "No upcoming follow-ups in the next 5 days.",
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.upcomingFollowups.length > 3 ? 3 : controller.upcomingFollowups.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final lead = controller.upcomingFollowups[index];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                                      child: const Icon(Icons.notifications_active, color: AppColors.warning),
                                    ),
                                    title: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text(lead.company, style: const TextStyle(fontSize: 12)),
                                    trailing: Text(lead.status, style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDashboardCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Active Tasks Queue",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            recentTasks.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: Center(
                                      child: Text(
                                        "No tasks registered in the system.",
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: recentTasks.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final task = recentTasks[index];
                                      final priority = task['priority']?.toString() ?? 'medium';
                                      final status = task['status']?.toString() ?? 'pending';
                                      final assignees = List.from(task['assignedTo'] ?? []);
                                      final assigneeNames = assignees.map((a) => a['name']).join(', ');

                                      Color priorityColor = Colors.grey;
                                      if (priority.toLowerCase() == 'high' || priority.toLowerCase() == 'urgent') {
                                        priorityColor = AppColors.danger;
                                      } else if (priority.toLowerCase() == 'medium') {
                                        priorityColor = AppColors.warning;
                                      }

                                      Color statusColor = Colors.grey;
                                      if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'done') {
                                        statusColor = AppColors.success;
                                      } else if (status.toLowerCase() == 'in-progress' || status.toLowerCase() == 'in progress') {
                                        statusColor = AppColors.primary;
                                      } else {
                                        statusColor = AppColors.textSecondary;
                                      }

                                      return _HoverListTile(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    task['title']?.toString() ?? 'Untitled Task',
                                                    style: const TextStyle(
                                                      color: AppColors.textPrimary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: priorityColor.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: priorityColor.withOpacity(0.2), width: 1),
                                                  ),
                                                  child: Text(
                                                    priority.toUpperCase(),
                                                    style: TextStyle(
                                                      color: priorityColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              task['description']?.toString() ?? '',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Assigned to: ${assigneeNames.isNotEmpty ? assigneeNames : 'Unassigned'}",
                                                    style: const TextStyle(
                                                      color: AppColors.textSecondary,
                                                      fontSize: 13,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: statusColor.withOpacity(0.2), width: 1),
                                                  ),
                                                  child: Text(
                                                    status.toUpperCase(),
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDashboardCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Personnel Distribution by Department",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            byDepartment.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        "No department data available.",
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: byDepartment.length,
                                    itemBuilder: (context, index) {
                                      final dept = byDepartment[index];
                                      final deptName = dept['_id'] ?? 'Unknown';
                                      final count = dept['count'] ?? 0;
                                      final pct = totalEmployees > 0 ? (count / totalEmployees) : 0.0;

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  deptName,
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  "$count member${count == 1 ? '' : 's'}",
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: pct,
                                                minHeight: 8,
                                                backgroundColor: Colors.grey[200],
                                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (isDesktop) ...[
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: _buildDashboardCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Recently Joined Members",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          recentEmployees.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(
                                      "No recent employees found.",
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: recentEmployees.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final emp = recentEmployees[index];
                                    final name = emp['name'] ?? 'Unknown';
                                    final dept = emp['department'] ?? 'General';
                                    final desig = emp['designation'] ?? 'Staff';

                                    return _HoverListTile(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primary.withOpacity(0.1),
                                            foregroundColor: AppColors.primary,
                                            child: Text(
                                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(
                                                  "$desig • $dept",
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 13,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            
            if (!isDesktop) ...[
              const SizedBox(height: 24),
              _buildDashboardCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recently Joined Members",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    recentEmployees.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                "No recent employees found.",
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentEmployees.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final emp = recentEmployees[index];
                              final name = emp['name'] ?? 'Unknown';
                              final dept = emp['department'] ?? 'General';
                              final desig = emp['designation'] ?? 'Staff';

                              return _HoverListTile(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary.withOpacity(0.1),
                                      foregroundColor: AppColors.primary,
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            "$desig • $dept",
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
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
                  ],
                ),
              ),
          ],
        ],
        ),
      ),
    );
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
    final totalCalls = state.callLogs.length;

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 1 : (width < 1200 ? 2 : 4);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          _buildGreetingHeaderCard(
            context: context,
            userName: state.currentUser?.name ?? 'Super Admin',
            subtitle: "Here's what is happening with your workforce and sales pipelines today.",
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
                title: "Sales Calls",
                value: "$totalCalls Logged",
                changeText: "Overall",
                isPositive: true,
                icon: Icons.phone_in_talk,
                iconBgColor: const Color(0xFFE0E7FF),
                iconColor: AppColors.primary,
              ),
              MetricCard(
                title: "Total Revenue (Won)",
                value: "₹${wonLeadsValue.toStringAsFixed(0)}",
                changeText: "+14.2%",
                isPositive: true,
                icon: Icons.monetization_on_outlined,
              ),
              MetricCard(
                title: "Pipeline Potential",
                value: "₹${pipelineValue.toStringAsFixed(0)}",
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
                  child: Column(
                    children: [
                      _buildRecentCallsLog(context, state),
                      const SizedBox(height: 24),
                      _buildSystemNotificationsLog(context, state),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (width < 1000) ...[
            const SizedBox(height: 24),
            _buildRecentCallsLog(context, state),
            const SizedBox(height: 24),
            _buildSystemNotificationsLog(context, state),
          ],
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
          _buildGreetingHeaderCard(
            context: context,
            userName: state.currentUser?.name ?? 'HR Manager',
            subtitle: "HR Control Center: Monitor personnel, approve leave requests, and track company assets.",
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
                    _buildDashboardCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pending Leave Approval Queue",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
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
                                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final req = state.leaveRequests.where((l) => l.status.toLowerCase() == 'pending').toList()[index];
                                    return _HoverListTile(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      child: Row(
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
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "${req.type} | ${req.reason}",
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 14,
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
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDashboardCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hardware Asset Overview",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.assets.take(3).length,
                            separatorBuilder: (context, index) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final asset = state.assets[index];
                              return _HoverListTile(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      asset.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      asset.assignedTo,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
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
          _buildGreetingHeaderCard(
            context: context,
            userName: state.currentUser?.name ?? 'Employee',
            subtitle: "Employee Portal: View active tasks, submit leaves, and track daily attendance shifts.",
            trailing: _buildWorkingStatusDropdown(state),
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
                    _buildDashboardCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "My Assigned Tasks",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
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
                                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                                  itemBuilder: (context, index) {
                                    final task = myTasks[index];
                                    return _HoverListTile(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      child: Row(
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
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  task.description,
                                                  style: const TextStyle(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 14,
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
                                      ),
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

  Widget _buildWorkingStatusDropdown(MockDataService state) {
    return StatefulBuilder(
      builder: (context, setState) {
        String currentStatus = state.currentUser?.workingStatus ?? 'Available';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentStatus,
              dropdownColor: AppColors.sidebarBackground,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              items: ['Available', 'On Call', 'In Meeting', 'Offline']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  state.updateWorkingStatus(val);
                }
              },
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---
  Widget _buildRecentCallsLog(BuildContext context, MockDataService state) {
    final recentCalls = state.callLogs.take(5).toList();

    return _buildDashboardCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Call Activity",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          recentCalls.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text("No calls logged.", style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentCalls.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = recentCalls[index];
                    Color outcomeColor = AppColors.success;
                    if (log.outcome == 'No Answer' || log.outcome == 'Voicemail') outcomeColor = AppColors.warning;
                    if (log.outcome == 'Busy') outcomeColor = AppColors.danger;

                    return _HoverListTile(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: outcomeColor.withValues(alpha: 0.1),
                            child: Icon(Icons.phone_in_talk, color: outcomeColor, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${log.employeeName} → ${log.leadName}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${log.durationMinutes} min • ${log.outcome}",
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildSystemNotificationsLog(BuildContext context, MockDataService state) {
    return SizedBox(
      height: 600,
      child: _buildDashboardCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "System Notifications Log",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final item = state.notifications[index];
                  return _HoverListTile(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: item.isRead ? Colors.grey[300] : AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: item.isRead ? [] : [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ],
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
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.message,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
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
    );
  }

  Widget _buildChartCard(String title, Widget chartWidget) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              fontSize: 18,
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

  Widget _buildGreetingHeaderCard({
    required BuildContext context,
    required String userName,
    required String subtitle,
    Widget? trailing,
  }) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    IconData greetingIcon;
    Color iconColor;

    if (hour >= 5 && hour < 12) {
      greeting = "Good morning";
      greetingIcon = Icons.wb_sunny_outlined;
      iconColor = Colors.amber;
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good afternoon";
      greetingIcon = Icons.light_mode;
      iconColor = Colors.orangeAccent;
    } else {
      greeting = "Good evening";
      greetingIcon = Icons.nights_stay_outlined;
      iconColor = Colors.indigoAccent;
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            AppColors.sidebarBackground, // Dark slate
            Color(0xFF272F3F),          // Slightly lighter slate/navy
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(greetingIcon, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "$greeting,",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: isMobile ? 12 : 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
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
    const double paddingLeft = 45.0;
    const double paddingBottom = 20.0;
    const double paddingTop = 15.0;
    const double paddingRight = 15.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final paintGrid = Paint()
      ..color = AppColors.border.withOpacity(0.6)
      ..strokeWidth = 1.0;

    // Draw Y-axis grid lines and labels
    final gridCount = 4;
    final yLabels = ['₹0', '₹25k', '₹50k', '₹75k', '₹100k'];
    for (int i = 0; i <= gridCount; i++) {
      final y = paddingTop + chartHeight * (1 - i / gridCount);
      canvas.drawLine(Offset(paddingLeft, y), Offset(paddingLeft + chartWidth, y), paintGrid);

      // Y-axis Label
      final textSpan = TextSpan(
        text: yLabels[i],
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // X-axis Labels
    final xLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final xStep = chartWidth / (xLabels.length - 1);
    for (int i = 0; i < xLabels.length; i++) {
      final x = paddingLeft + i * xStep;
      
      final textSpan = TextSpan(
        text: xLabels[i],
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, paddingTop + chartHeight + 4),
      );
    }

    // Points of the Revenue Wave mapped to padding coordinates
    final rawYPercentages = [0.75, 0.60, 0.85, 0.35, 0.45, 0.15];
    final points = <Offset>[];
    for (int i = 0; i < rawYPercentages.length; i++) {
      final x = paddingLeft + i * xStep;
      final y = paddingTop + chartHeight * rawYPercentages[i];
      points.add(Offset(x, y));
    }

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

    // Fill Path with Gradient
    final fillPath = Path.from(path);
    fillPath.lineTo(paddingLeft + chartWidth, paddingTop + chartHeight);
    fillPath.lineTo(paddingLeft, paddingTop + chartHeight);
    fillPath.close();

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.24),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(paddingLeft, paddingTop, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, paintFill);

    // Glowing Line shadow
    final paintShadow = Paint()
      ..color = AppColors.primary.withOpacity(0.18)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paintShadow);

    // Bright curves line
    final paintLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paintLine);

    // Draw vertical indicator line for the latest month (June)
    final latestPt = points.last;
    final paintIndicator = Paint()
      ..color = AppColors.primary.withOpacity(0.4)
      ..strokeWidth = 1.0;
    
    // Draw indicator line
    canvas.drawLine(
      Offset(latestPt.dx, paddingTop),
      Offset(latestPt.dx, paddingTop + chartHeight),
      paintIndicator,
    );

    // Draw point nodes
    final paintDots = Paint()..color = AppColors.primary;
    final paintWhite = Paint()..color = Colors.white;
    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isLast = i == points.length - 1;
      
      canvas.drawCircle(pt, isLast ? 6.0 : 4.5, paintDots);
      canvas.drawCircle(pt, isLast ? 3.0 : 2.0, paintWhite);
    }

    // Draw glowing tooltip for the latest point
    final tooltipRect = Rect.fromCenter(
      center: Offset(latestPt.dx - 45, latestPt.dy - 24),
      width: 78,
      height: 22,
    );
    final rrect = RRect.fromRectAndRadius(tooltipRect, const Radius.circular(6));
    final paintTooltipBg = Paint()..color = AppColors.sidebarBackground;
    canvas.drawRRect(rrect, paintTooltipBg);

    final textSpan = const TextSpan(
      text: '₹85,000 (Jun)',
      style: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(tooltipRect.left + (tooltipRect.width - textPainter.width) / 2,
             tooltipRect.top + (tooltipRect.height - textPainter.height) / 2),
    );
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

        Color barColor;
        switch (stage) {
          case 'New':
            barColor = AppColors.info;
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

        return _LeadBarItem(
          stage: stage,
          count: count,
          percentage: pct,
          barColor: barColor,
        );
      }).toList(),
    );
  }
}

class _LeadBarItem extends StatefulWidget {
  final String stage;
  final int count;
  final double percentage;
  final Color barColor;

  const _LeadBarItem({
    required this.stage,
    required this.count,
    required this.percentage,
    required this.barColor,
  });

  @override
  State<_LeadBarItem> createState() => _LeadBarItemState();
}

class _LeadBarItemState extends State<_LeadBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const double maxBarHeight = 140.0;
    final barHeight = maxBarHeight * widget.percentage;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "${widget.count}",
              style: TextStyle(
                color: _isHovered ? widget.barColor : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Background Track
                Container(
                  width: 32,
                  height: maxBarHeight,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Filled bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  width: 32,
                  height: barHeight < 8 ? 8 : barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.barColor,
                        widget.barColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: _isHovered ? [
                      BoxShadow(
                        color: widget.barColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ] : [],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.stage,
              style: TextStyle(
                color: _isHovered ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _DashboardAttendanceCard extends StatefulWidget {
  final MockDataService state;
  const _DashboardAttendanceCard({super.key, required this.state});

  @override
  State<_DashboardAttendanceCard> createState() => _DashboardAttendanceCardState();
}

class _DashboardAttendanceCardState extends State<_DashboardAttendanceCard> with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
    _pulseController.dispose();
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
        Row(
          children: [
            if (isPunched) ...[
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final double pulseVal = _pulseController.value;
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.4 * (1 - pulseVal)),
                          blurRadius: 10 * pulseVal,
                          spreadRadius: 6 * pulseVal,
                        )
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
            Text(
              isPunched ? "Active Work Shift" : "Shift Attendance Status",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isPunched) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.success, size: 18),
                const SizedBox(width: 10),
                Text(
                  _formatDuration(_elapsed),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Shift started at ${widget.state.todayAttendance?.checkInTime ?? ''}",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: AppColors.danger, size: 16),
                const SizedBox(width: 8),
                const Text(
                  "Not clocked-in for today yet",
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    final actionButton = CustomButton(
      text: isPunched ? "Clock Out" : "Clock In",
      icon: isPunched ? Icons.logout : Icons.fingerprint,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                const SizedBox(height: 20),
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

class _HoverListTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const _HoverListTile({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  });

  @override
  State<_HoverListTile> createState() => _HoverListTileState();
}

class _HoverListTileState extends State<_HoverListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
