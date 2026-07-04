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
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.isRegistered<CrmController>()
          ? Get.find<CrmController>()
          : null;
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
      final controller = Get.isRegistered<CrmController>()
          ? Get.find<CrmController>()
          : null;
      final isLoading = controller?.isLoadingAttendance.value ?? false;
      final error = controller?.attendanceError.value;

      final rawLogs = controller?.attendanceLogs.isNotEmpty == true
          ? controller!.attendanceLogs
          : state.attendanceLogs;

      final isAdmin =
          state.currentRole == UserRole.superAdmin ||
          state.currentRole == UserRole.hr;
      final currentLogs = isAdmin
          ? rawLogs
          : rawLogs
                .where(
                  (a) =>
                      a.employeeId == state.currentUser?.id ||
                      a.employeeId == state.currentUser?.employeeId,
                )
                .toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Attendance",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Filter Bar Card
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
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    children: [
                      // Employee Dropdown
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "EMPLOYEE",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: 'All Employees',
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'All Employees',
                                  child: Text('All Employees'),
                                ),
                              ],
                              onChanged: (val) {},
                            ),
                          ],
                        ),
                      ),
                      // From Date
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "FROM",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => _startDate = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${_startDate.day.toString().padLeft(2, '0')} - ${_getMonthName(_startDate.month)} - ${_startDate.year}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // To Date
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "TO",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => _endDate = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${_endDate.day.toString().padLeft(2, '0')} - ${_getMonthName(_endDate.month)} - ${_endDate.year}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Dropdown
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "STATUS",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: 'All Status',
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'All Status',
                                  child: Text('All Status'),
                                ),
                                DropdownMenuItem(
                                  value: 'Present',
                                  child: Text('Present'),
                                ),
                                DropdownMenuItem(
                                  value: 'Absent',
                                  child: Text('Absent'),
                                ),
                              ],
                              onChanged: (val) {},
                            ),
                          ],
                        ),
                      ),
                      // Filter Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ), // Matches screenshot "Filter" purple/blue
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (controller != null) {
                            controller.fetchAttendance(
                              startDate: _formatDate(_startDate),
                              endDate: _formatDate(_endDate),
                            );
                          }
                        },
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text(
                          "Filter",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Export Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF10B981,
                      ), // Matches screenshot "Export" green
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.insert_drive_file, size: 18),
                    label: const Text(
                      "Export",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              "${currentLogs.length} record(s) found",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),

            // Table Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : error != null
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  : currentLogs.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          "No records found",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingTextStyle: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        dataTextStyle: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        dividerThickness: 1,
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey[50],
                        ),
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 60,
                        columns: const [
                          DataColumn(label: Text("EMPLOYEE")),
                          DataColumn(label: Text("EMP ID")),
                          DataColumn(label: Text("DATE")),
                          DataColumn(label: Text("LOGIN TIME")),
                          DataColumn(label: Text("LOGOUT TIME")),
                          DataColumn(label: Text("HOURS")),
                          DataColumn(label: Text("STATUS")),
                          DataColumn(label: Text("LOCATION")),
                        ],
                        rows: currentLogs.map((log) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  log.employeeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  log.employeeId,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${log.date.day.toString().padLeft(2, '0')} ${_getMonthName(log.date.month)} ${log.date.year}",
                                ),
                              ),
                              DataCell(Text(log.checkInTime)),
                              DataCell(Text(log.checkOutTime ?? '--')),
                              DataCell(
                                Text(
                                  log.durationHours != null
                                      ? "${log.durationHours!.toStringAsFixed(2)}h"
                                      : "0h",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        log.status == 'Present' ||
                                            log.status == 'On Time'
                                        ? const Color(0xFFD1FAE5)
                                        : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    log.status,
                                    style: TextStyle(
                                      color:
                                          log.status == 'Present' ||
                                              log.status == 'On Time'
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFDC2626),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const DataCell(
                                Text(
                                  "Office",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
