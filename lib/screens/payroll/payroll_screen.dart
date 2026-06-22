import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../services/mock_data_service.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  void _showPayslipDialog(BuildContext context, String month, double basePay, double bonus, double tax, double insurance) {
    final netSalary = (basePay + bonus) - (tax + insurance);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header invoice style
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bolt, color: AppColors.primary, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "RidealCRM Corp",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "PAID",
                        style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "SALARY SLIP FOR $month",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text("Payment Date: 28th of current month", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),

                // Earnings Section
                const Text("EARNINGS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                _buildSlipItem("Base Salary", "\$${basePay.toStringAsFixed(2)}"),
                _buildSlipItem("Performance Allowance", "\$${bonus.toStringAsFixed(2)}"),
                const SizedBox(height: 16),

                // Deductions Section
                const Text("DEDUCTIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                _buildSlipItem("Provident Fund / Tax (12%)", "-\$${tax.toStringAsFixed(2)}", isDeduction: true),
                _buildSlipItem("Medical Insurance Contribution", "-\$${insurance.toStringAsFixed(2)}", isDeduction: true),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),

                // Net Pay Highlight
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "NET TAKE-HOME PAY",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    Text(
                      "\$${netSalary.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close", style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      text: "Print Payslip",
                      icon: Icons.print_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Simulating printer dispatch... Success.")),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlipItem(String label, String value, {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDeduction ? AppColors.danger : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final user = state.currentUser;

    if (user == null) {
      return const Center(child: Text("Please sign in to view payroll ledger."));
    }

    // Dynamic calculations based on user's annual salary
    final monthlyBase = user.salary / 12;
    final monthlyBonus = (user.performanceRating >= 4.5) ? (monthlyBase * 0.12) : (monthlyBase * 0.05);
    final taxDeduction = monthlyBase * 0.12;
    final medicalDeduction = 150.00;
    final netTakeHome = (monthlyBase + monthlyBonus) - (taxDeduction + medicalDeduction);

    final ledgerMonths = ["May 2026", "April 2026", "March 2026", "February 2026"];
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
                "Compensation & Payroll",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "View monthly salary receipts, allowances, taxes, and printable slip files.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Core details panel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Breakdown Card
              Expanded(
                flex: width < 1000 ? 1 : 2,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Current Month Pay Breakdown",
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          _buildBreakdownProgress("Net Take-Home Pay (Liquid)", netTakeHome, monthlyBase + monthlyBonus, AppColors.primary),
                          const SizedBox(height: 16),
                          _buildBreakdownProgress("Income Tax Withholding (12%)", taxDeduction, monthlyBase + monthlyBonus, AppColors.danger),
                          const SizedBox(height: 16),
                          _buildBreakdownProgress("Medical Insurance Premium", medicalDeduction, monthlyBase + monthlyBonus, AppColors.warning),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 16),
                          width < 600
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Net Paid Amount", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "\$${netTakeHome.toStringAsFixed(2)}",
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: CustomButton(
                                        text: "View Payslip Receipt",
                                        icon: Icons.receipt_long,
                                        onPressed: () => _showPayslipDialog(
                                          context,
                                          "May 2026",
                                          monthlyBase,
                                          monthlyBonus,
                                          taxDeduction,
                                          medicalDeduction,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Net Paid Amount", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text(
                                            "\$${netTakeHome.toStringAsFixed(2)}",
                                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    CustomButton(
                                      text: "View Payslip Receipt",
                                      icon: Icons.receipt_long,
                                      onPressed: () => _showPayslipDialog(
                                        context,
                                        "May 2026",
                                        monthlyBase,
                                        monthlyBonus,
                                        taxDeduction,
                                        medicalDeduction,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ledger table card
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
                            "Historical Payslips Log",
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ledgerMonths.length,
                            separatorBuilder: (context, idx) => const Divider(color: AppColors.border, height: 1),
                            itemBuilder: (context, idx) {
                              final mth = ledgerMonths[idx];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.picture_as_pdf_outlined, color: AppColors.danger, size: 22),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Payslip_$mth.pdf",
                                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  "Status: Dispatched",
                                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _showPayslipDialog(
                                        context,
                                        mth,
                                        monthlyBase,
                                        monthlyBonus,
                                        taxDeduction,
                                        medicalDeduction,
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        minimumSize: const Size(60, 32),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text("Open Receipt", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
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

              // Policy Note (Right column on desktop)
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
                          "Annual Tax & Bonuses",
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        _buildPolicyItem("Federal Tax Deduction", "Standard 12% applied automatically to monthly gross wages."),
                        _buildPolicyItem("Performance Accrual", "Up to 12% bonuses granted for Q1/Q2/Q3/Q4 KPI score cards above 4.5."),
                        _buildPolicyItem("Healthcare Contributions", "Includes Dental, Medical and Life insurance coverages."),
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

  Widget _buildBreakdownProgress(String label, double amount, double total, Color color) {
    final pct = total > 0 ? (amount / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Text("\$${amount.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          color: color,
          backgroundColor: Colors.grey[200],
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildPolicyItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}
