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

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    String text;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        bgColor = Colors.green.withOpacity(0.12);
        text = "Approved";
        break;
      case 'reviewed':
        color = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.12);
        text = "Reviewed";
        break;
      case 'submitted':
      default:
        color = AppColors.primary;
        bgColor = AppColors.primary.withOpacity(0.12);
        text = "Submitted";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showReviewReportDialog(BuildContext context, DailyReport report) {
    final formKey = GlobalKey<FormState>();
    final reviewNoteCtrl = TextEditingController(text: report.reviewNote);
    String selectedStatus = 'approved';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              title: Text(
                "Review Report for ${report.employeeName}",
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Review Status",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text("Approve"),
                            selected: selectedStatus == 'approved',
                            selectedColor: Colors.green.withOpacity(0.12),
                            labelStyle: TextStyle(
                              color: selectedStatus == 'approved' ? Colors.green : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  selectedStatus = 'approved';
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text("Mark Reviewed"),
                            selected: selectedStatus == 'reviewed',
                            selectedColor: Colors.orange.withOpacity(0.12),
                            labelStyle: TextStyle(
                              color: selectedStatus == 'reviewed' ? Colors.orange : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  selectedStatus = 'reviewed';
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Review Comments / Notes",
                        hint: "Write feedback, queries, or appreciation...",
                        prefixIcon: Icons.rate_review_outlined,
                        controller: reviewNoteCtrl,
                        validator: (val) => val == null || val.isEmpty ? "Review note is required" : null,
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
                  text: "Submit Review",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (Get.isRegistered<CrmController>()) {
                        Get.find<CrmController>().reviewDailyReport(
                          report.id,
                          selectedStatus,
                          reviewNoteCtrl.text,
                        );
                      }
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSubmitReportDialog(BuildContext context, MockDataService state) {
    final formKey = GlobalKey<FormState>();
    final summaryCtrl = TextEditingController();
    final tasksCtrl = TextEditingController();
    final blocksCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: "8.0");

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
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Hours Worked",
                    hint: "e.g. 8.0",
                    prefixIcon: Icons.access_time_rounded,
                    controller: hoursCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Hours worked is required";
                      final numVal = double.tryParse(val);
                      if (numVal == null) return "Enter a valid number";
                      if (numVal <= 0 || numVal > 24) return "Must be between 0.1 and 24";
                      return null;
                    },
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
                    hoursWorked: double.tryParse(hoursCtrl.text),
                    status: 'submitted',
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
    final isPrivileged = state.currentRole == UserRole.superAdmin || state.currentRole == UserRole.hr;

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
                          Row(
                            children: [
                              _buildStatusBadge(report.status),
                              if (isPrivileged) ...[
                                const SizedBox(width: 12),
                                InkWell(
                                  onTap: () => _showReviewReportDialog(context, report),
                                  borderRadius: BorderRadius.circular(4),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Row(
                                      children: [
                                        Icon(Icons.rate_review_outlined, color: AppColors.primary, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          "Review",
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
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
                      const SizedBox(height: 12),

                      // Time and Date Row
                      Row(
                        children: [
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (report.hoursWorked != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${report.hoursWorked} hrs worked",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
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

                      // Review comments note if reviewNote exists
                      if (report.reviewNote.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.rate_review_outlined, color: AppColors.primary, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Review Notes ${report.reviewedByName.isNotEmpty ? 'by ' + report.reviewedByName : ''}",
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                report.reviewNote,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 12.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
