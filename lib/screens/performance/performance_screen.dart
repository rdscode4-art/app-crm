import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/mock_data_service.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final records = state.performanceRecords;
    final width = MediaQuery.of(context).size.width;

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
                "Performance Tracking",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Monitor company KPIs, rating scorecards, and manager reviews.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Overview Statistics Section (Responsive)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main ratings list
              Expanded(
                flex: width < 1000 ? 1 : 2,
                child: Column(
                  children: [
                    // Evaluation Scorecard Feed
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
                          const Text(
                            "Employee Evaluation Logs",
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          if (records.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text("No performance records cataloged.", style: TextStyle(color: AppColors.textSecondary)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: records.length,
                              separatorBuilder: (context, idx) => const Divider(color: AppColors.border, height: 1),
                              itemBuilder: (context, idx) {
                                final record = records[idx];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Circle score display
                                      _buildScoreBadge(record.kpiScore),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              record.employeeName,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  "Period: ${record.period}",
                                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text("•", style: TextStyle(color: AppColors.textSecondary)),
                                                const SizedBox(width: 8),
                                                Row(
                                                  children: List.generate(
                                                    5,
                                                    (index) => Icon(
                                                      index < record.ratingStars ? Icons.star : Icons.star_border,
                                                      color: Colors.amber,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AppColors.border),
                                              ),
                                              child: Text(
                                                "\"${record.managerFeedback}\"",
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 12,
                                                  height: 1.4,
                                                ),
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
                ),
              ),

              // KPI targets checklist (Visible on desktop only)
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
                          "Corporate KPI Metric Scales",
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        _buildKpiMetric("90% - 100%", "EXEMPLARY PERFORMER", "Consistently exceeds goals, exhibits strong leadership, guides teams.", Colors.green),
                        _buildKpiMetric("75% - 89%", "SUCCESSFUL ACHIEVER", "Meets targets, delivers high quality work with minimal administration.", AppColors.primary),
                        _buildKpiMetric("50% - 74%", "NEEDS IMPROVEMENT", "Fails to hit pipeline potential or registers recurrent lateness logs.", Colors.orange),
                        _buildKpiMetric("0% - 49%", "UNSATISFACTORY", "Fails standard project checklists. Subject to formal review.", Colors.red),
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
  }

  Widget _buildScoreBadge(double score) {
    Color badgeColor = score >= 90
        ? Colors.green
        : (score >= 75 ? AppColors.primary : (score >= 50 ? Colors.orange : Colors.red));

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1.5),
      ),
      child: Center(
        child: Text(
          "${score.toStringAsFixed(0)}%",
          style: TextStyle(
            color: badgeColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiMetric(String range, String label, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                range,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(width: 6),
              const Text("-", style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}
