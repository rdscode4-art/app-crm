import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services/mock_data_service.dart';
import '../../models/daily_report.dart';
import '../../controllers/crm_controller.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<CrmController>()) {
        Get.find<CrmController>().fetchDailyReports();
      }
    });
  }

  void _showSubmitReportDialog(BuildContext context, MockDataService state) {
    final formKey = GlobalKey<FormState>();
    final summaryCtrl = TextEditingController();
    final tasksCtrl = TextEditingController();
    final blocksCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          title: const Text(
            "File Daily Progress Report",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: "Today's Work Summary",
                    hint: "Briefly explain what you worked on today...",
                    prefixIcon: Icons.description_outlined,
                    controller: summaryCtrl,
                    validator: (val) => val == null || val.isEmpty ? "Summary is required" : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Tasks Completed",
                    hint: "e.g. Stark Proposal sent, Refactored Auth API",
                    prefixIcon: Icons.task_alt,
                    controller: tasksCtrl,
                    validator: (val) => val == null || val.isEmpty ? "Completed tasks list is required" : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Blockers / Impediments",
                    hint: "e.g. API down, Waiting for assets (Write 'None' if none)",
                    prefixIcon: Icons.block_outlined,
                    controller: blocksCtrl,
                    validator: (val) => val == null || val.isEmpty ? "Blockers description is required" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
            ),
            CustomButton(
              text: "Submit Report",
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newReport = DailyReport(
                    id: "REP-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                    employeeName: state.currentUser?.name ?? "Anonymous Employee",
                    date: DateTime.now(),
                    summary: summaryCtrl.text,
                    tasksCompleted: tasksCtrl.text,
                    blocks: blocksCtrl.text,
                  );
                  if (Get.isRegistered<CrmController>()) {
                    Get.find<CrmController>().submitDailyReport(newReport);
                    state.addNotification("Daily Report Filed", "Report successfully submitted by ${newReport.employeeName}.");
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();

    return Obx(() {
      final list = state.dailyReports;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daily Work Reports",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Log daily completions, roadblocks, and coordinate team progress updates.",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CustomButton(
                  text: "File Report",
                  icon: Icons.edit_note,
                  onPressed: () => _showSubmitReportDialog(context, state),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Reports Feed List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final report = list[index];
                final dateStr = "${report.date.day}/${report.date.month}/${report.date.year}";

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary.withOpacity(0.12),
                                child: Text(
                                  report.employeeName.isNotEmpty ? report.employeeName[0] : 'E',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                report.employeeName,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Summary Section
                      const Text(
                        "SUMMARY",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.summary,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Split tasks and blockers
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.task_alt, color: AppColors.primary, size: 14),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "TASKS COMPLETED",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  report.tasksCompleted,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.block_outlined,
                                      color: report.blocks.toLowerCase() == 'none' ? Colors.grey : AppColors.danger,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    const Expanded(
                                      child: Text(
                                        "ROADBLOCKS / BLOCKERS",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  report.blocks,
                                  style: TextStyle(
                                    color: report.blocks.toLowerCase() == 'none' ? AppColors.textSecondary : AppColors.danger,
                                    fontSize: 13,
                                    fontWeight: report.blocks.toLowerCase() == 'none' ? FontWeight.normal : FontWeight.w500,
                                  ),
                                ),
                              ],
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
      );
    });
  }
}
