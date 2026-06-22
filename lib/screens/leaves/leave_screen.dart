import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services/mock_data_service.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  void _showRequestLeaveDialog(BuildContext context, MockDataService state) {
    final formKey = GlobalKey<FormState>();
    final reasonCtrl = TextEditingController();
    String type = 'Casual';
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 2));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> selectDateRange() async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: DateTimeRange(start: startDate, end: endDate),
              );
              if (picked != null) {
                setDialogState(() {
                  startDate = picked.start;
                  endDate = picked.end;
                });
              }
            }

            final dateText = "${startDate.day}/${startDate.month}/${startDate.year} to ${endDate.day}/${endDate.month}/${endDate.year}";

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              title: const Text(
                "Request Leave",
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
                      const Text(
                        "Leave Type",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border, width: 1.5),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: type,
                            isExpanded: true,
                            items: ['Casual', 'Sick', 'Annual']
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s, style: const TextStyle(fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  type = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Leave Duration Dates",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: selectDateRange,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border, width: 1.5),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateText, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                              const Icon(Icons.calendar_month, color: AppColors.textSecondary, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Reason for Time-Off",
                        hint: "Brief explanation of leave reason...",
                        prefixIcon: Icons.notes_outlined,
                        controller: reasonCtrl,
                        validator: (val) => val == null || val.isEmpty ? "Reason is required" : null,
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
                  text: "Submit Application",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      state.submitLeaveRequest(type, startDate, endDate, reasonCtrl.text);
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

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final isAdmin = state.currentUser?.id == "EMP-001"; // Diana Prince has admin approval privileges
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 600 ? double.infinity : 220.0;
    final badgeText = screenWidth < 600 ? "Admin" : "HR Administrator View";

    return AnimatedBuilder(
      animation: state,
      builder: (context, child) {
        final currentRequests = state.leaveRequests;
        // Balance values (mocked representation)
        final casualUsed = currentRequests.where((l) => l.employeeId == state.currentUser?.id && l.type == 'Casual' && l.status == 'Approved').length * 2;
        final sickUsed = currentRequests.where((l) => l.employeeId == state.currentUser?.id && l.type == 'Sick' && l.status == 'Approved').length * 1;
        final annualUsed = currentRequests.where((l) => l.employeeId == state.currentUser?.id && l.type == 'Annual' && l.status == 'Approved').length * 5;

        final casualTotal = 12;
        final sickTotal = 10;
        final annualTotal = 20;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Time-Off & Leave Management",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Review leave balances, request paid time-off, and track approvals.",
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
                    text: "Apply Leave",
                    icon: Icons.add,
                    onPressed: () => _showRequestLeaveDialog(context, state),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Balances Gauge Section (Responsive)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildBalanceCard("Annual Leave Balance", annualUsed, annualTotal, Colors.blue, cardWidth),
                  _buildBalanceCard("Sick Leave Balance", sickUsed, sickTotal, Colors.red, cardWidth),
                  _buildBalanceCard("Casual Leave Balance", casualUsed, casualTotal, Colors.orange, cardWidth),
                ],
              ),
              const SizedBox(height: 28),

              // Leaves Requests list card table
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Leave Applications Logs",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shield_outlined, color: AppColors.primary, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  badgeText,
                                  style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (currentRequests.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text("No leave requests found.", style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentRequests.length,
                        separatorBuilder: (context, idx) => const Divider(color: AppColors.border, height: 1),
                        itemBuilder: (context, idx) {
                          final req = currentRequests[idx];
                          final durationText = "${req.startDate.day}/${req.startDate.month} - ${req.endDate.day}/${req.endDate.month}";

                          Color statusColor;
                          switch (req.status) {
                            case 'Approved':
                              statusColor = AppColors.success;
                              break;
                            case 'Pending':
                              statusColor = AppColors.warning;
                              break;
                            default:
                              statusColor = AppColors.danger;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: statusColor.withOpacity(0.1),
                                  child: Icon(
                                    req.type == 'Sick'
                                        ? Icons.medication_outlined
                                        : (req.type == 'Casual' ? Icons.beach_access_outlined : Icons.flight_takeoff_outlined),
                                    color: statusColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${req.employeeName} (${req.type} Leave)",
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Duration: $durationText • Reason: ${req.reason}",
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        req.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // If HR admin and Pending, show quick approval toggles
                                    if (isAdmin && req.status == 'Pending') ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => state.updateLeaveStatus(req.id, 'Approved'),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.green[100]!),
                                              ),
                                              child: const Icon(Icons.check, color: Colors.green, size: 12),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () => state.updateLeaveStatus(req.id, 'Rejected'),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red[50],
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.red[100]!),
                                              ),
                                              child: const Icon(Icons.close, color: Colors.red, size: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
        );
      },
    );
  }

  Widget _buildBalanceCard(String title, int used, int total, Color color, double cardWidth) {
    final remaining = total - used;
    final pct = total > 0 ? (remaining / total) : 0.0;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "$remaining",
                      style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "/$total days left",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: pct,
              strokeWidth: 5,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
