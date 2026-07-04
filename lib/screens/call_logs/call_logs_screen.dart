import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../controllers/crm_controller.dart';

class CallLogsScreen extends StatefulWidget {
  const CallLogsScreen({super.key});

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  final CrmController controller = Get.find<CrmController>();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCallLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Call Logs Monitor",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => controller.fetchCallLogs(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Refresh"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Obx(() {
            if (controller.isLoadingCallLogs.value) {
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final logs = controller.callLogs.where((log) {
              final search = _searchQuery.toLowerCase();
              return log.employeeName.toLowerCase().contains(search) ||
                  log.leadName.toLowerCase().contains(search) ||
                  log.outcome.toLowerCase().contains(search);
            }).toList();

            final today = DateTime.now();
            final callsToday = controller.callLogs
                .where(
                  (l) =>
                      l.timestamp.year == today.year &&
                      l.timestamp.month == today.month &&
                      l.timestamp.day == today.day,
                )
                .length;

            final totalDuration = controller.callLogs.fold<int>(
              0,
              (sum, log) => sum + log.durationMinutes,
            );
            final connectedCalls = controller.callLogs
                .where((l) => l.outcome.toLowerCase() == 'connected')
                .length;

            return Expanded(
              child: Column(
                children: [
                  _buildMetricsRow(
                    callsToday,
                    totalDuration,
                    connectedCalls,
                    isMobile,
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        hintText: "Search by Employee, Lead, or Outcome...",
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Table
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: logs.isEmpty
                          ? const Center(child: Text("No call logs found."))
                          : ListView.separated(
                              padding: const EdgeInsets.all(0),
                              itemCount: logs.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    color: AppColors.border,
                                  ),
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                final t = log.timestamp;
                                final dateStr =
                                    "${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} • ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

                                Color outcomeColor = AppColors.textSecondary;
                                if (log.outcome.toLowerCase() == 'connected')
                                  outcomeColor = Colors.green;
                                if (log.outcome.toLowerCase() == 'no answer')
                                  outcomeColor = Colors.orange;
                                if (log.outcome.toLowerCase() == 'busy')
                                  outcomeColor = Colors.red;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    child: const Icon(
                                      Icons.call,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          log.leadName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${log.durationMinutes} min",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            log.employeeName,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            dateStr,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (log.notes.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          log.notes,
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: outcomeColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      log.outcome,
                                      style: TextStyle(
                                        color: outcomeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(
    int callsToday,
    int totalDuration,
    int connectedCalls,
    bool isMobile,
  ) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "Calls Today",
                  callsToday.toString(),
                  Icons.phone_callback,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "Total Minutes",
                  totalDuration.toString(),
                  Icons.timer,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            "Connected Calls",
            connectedCalls.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            "Calls Today",
            callsToday.toString(),
            Icons.phone_callback,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            "Total Minutes",
            totalDuration.toString(),
            Icons.timer,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            "Connected Calls",
            connectedCalls.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
