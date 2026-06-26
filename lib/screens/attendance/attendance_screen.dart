import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/crm_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../services/mock_data_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.isRegistered<CrmController>() ? Get.find<CrmController>() : null;
      if (controller != null) {
        controller.fetchAttendance(
          startDate: _formatDate(_startDate),
          endDate: _formatDate(_endDate),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final controller = Get.isRegistered<CrmController>() ? Get.find<CrmController>() : null;
      final isLoading = controller?.isLoadingAttendance.value ?? false;
      final error = controller?.attendanceError.value;

      final isAdmin = state.currentRole == UserRole.superAdmin || state.currentRole == UserRole.hr;
      final currentLogs = isAdmin
          ? state.attendanceLogs
          : state.attendanceLogs.where((a) => a.employeeId == state.currentUser?.id).toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Time & Attendance",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Review employee shift logs and historical attendance reports.",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dashboard Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Section: Shift Logs (Responsive)
                Expanded(
                  flex: width < 1000 ? 1 : 2,
                  child: Column(
                    children: [
                      // Shift History Card Table
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Attendance Shift History",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isAdmin)
                                  TextButton.icon(
                                    onPressed: () async {
                                      final picked = await showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime(2025, 1, 1),
                                        lastDate: DateTime(2027, 12, 31),
                                        initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _startDate = picked.start;
                                          _endDate = picked.end;
                                        });
                                        if (controller != null) {
                                          controller.fetchAttendance(
                                            startDate: _formatDate(_startDate),
                                            endDate: _formatDate(_endDate),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.date_range, size: 16, color: AppColors.primary),
                                    label: Text(
                                      "${_startDate.day}/${_startDate.month} - ${_endDate.day}/${_endDate.month}",
                                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                ),
                              )
                            else if (error != null)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                    "Error loading logs: $error",
                                    style: const TextStyle(color: AppColors.danger),
                                  ),
                                ),
                              )
                            else if (currentLogs.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                    "No shift logs recorded.",
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentLogs.length,
                                separatorBuilder: (context, idx) => const Divider(color: AppColors.border, height: 1),
                                itemBuilder: (context, idx) {
                                  final log = currentLogs[idx];
                                  final logDate = "${log.date.day}/${log.date.month}/${log.date.year}";

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  logDate,
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                if (isAdmin) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      log.employeeName,
                                                      style: TextStyle(color: Colors.grey[800], fontSize: 10, fontWeight: FontWeight.w500),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Check in: ${log.checkInTime} • Check out: ${log.checkOutTime ?? 'Active'}",
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: log.status == 'On Time' || log.status == 'Present'
                                                    ? AppColors.primary.withOpacity(0.1)
                                                    : AppColors.warning.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                log.status,
                                                style: TextStyle(
                                                  color: log.status == 'On Time' || log.status == 'Present'
                                                      ? AppColors.primary
                                                      : AppColors.warning,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (log.durationHours != null)
                                              Text(
                                                "${log.durationHours} hrs worked",
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 11,
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
                    ],
                  ),
                ),

                // Right Section: Shift Regulations & Policies (Hidden on Mobile)
                if (width >= 1000) ...[
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Container(
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
                            "Shift Rules & Policies",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPolicyRow("Standard Work hours", "09:00 AM - 06:00 PM"),
                          _buildPolicyRow("Grace Period", "30 minutes (Late after 09:30 AM)"),
                          _buildPolicyRow("Break Time Allowance", "1 hour lunch period"),
                          _buildPolicyRow("Overtime eligibility", "Requires director pre-approval"),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      "Automated Attendance",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Your monthly payroll computation automatically syncs with verified shift durations and check-in timelines.",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
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
    });
  }

  Widget _buildPolicyRow(String name, String policy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            policy,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
