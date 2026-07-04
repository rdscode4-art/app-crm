import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/crm_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../services/mock_data_service.dart';
import '../../models/payroll.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  int _selectedYear = 2026;
  int _selectedMonth = 7;

  final List<int> _years = [2024, 2025, 2026, 2027];
  final Map<int, String> _months = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPayroll();
    });
  }

  void _fetchPayroll() {
    if (Get.isRegistered<CrmController>()) {
      Get.find<CrmController>().fetchPayrolls(
        year: _selectedYear,
        month: _selectedMonth,
      );
    }
  }

  void _showPayslipDialog({
    required BuildContext context,
    required String month,
    required double basePay,
    required double hra,
    required double transport,
    required double medical,
    required double special,
    required double otherAllowance,
    required double tax,
    required double pf,
    required double insurance,
    required double loan,
    required double otherDeductions,
    required double totalEarnings,
    required double totalDeductions,
    required double netSalary,
    required String employeeName,
    required String status,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status.toLowerCase() == 'paid'
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: status.toLowerCase() == 'paid'
                                ? AppColors.primary
                                : AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "SALARY SLIP FOR $month",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Employee Name: $employeeName",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Payment Date: 28th of current month",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  // Earnings Section
                  const Text(
                    "EARNINGS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSlipItem(
                    "Base Salary",
                    "₹${basePay.toStringAsFixed(2)}",
                  ),
                  if (hra > 0)
                    _buildSlipItem(
                      "HRA (House Rent)",
                      "₹${hra.toStringAsFixed(2)}",
                    ),
                  if (transport > 0)
                    _buildSlipItem(
                      "Transport Allowance",
                      "₹${transport.toStringAsFixed(2)}",
                    ),
                  if (medical > 0)
                    _buildSlipItem(
                      "Medical Allowance",
                      "₹${medical.toStringAsFixed(2)}",
                    ),
                  if (special > 0)
                    _buildSlipItem(
                      "Special Allowance",
                      "₹${special.toStringAsFixed(2)}",
                    ),
                  if (otherAllowance > 0)
                    _buildSlipItem(
                      "Other Allowances",
                      "₹${otherAllowance.toStringAsFixed(2)}",
                    ),
                  if (hra + transport + medical + special + otherAllowance == 0)
                    _buildSlipItem("Performance Allowance", "₹0.00"),
                  _buildSlipItem(
                    "Total Gross Earnings",
                    "₹${totalEarnings.toStringAsFixed(2)}",
                    isBold: true,
                  ),
                  const SizedBox(height: 16),

                  // Deductions Section
                  const Text(
                    "DEDUCTIONS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSlipItem(
                    "Provident Fund (PF)",
                    "-₹${pf.toStringAsFixed(2)}",
                    isDeduction: true,
                  ),
                  _buildSlipItem(
                    "Income Tax Withholding",
                    "-₹${tax.toStringAsFixed(2)}",
                    isDeduction: true,
                  ),
                  _buildSlipItem(
                    "Medical Insurance Contribution",
                    "-₹${insurance.toStringAsFixed(2)}",
                    isDeduction: true,
                  ),
                  if (loan > 0)
                    _buildSlipItem(
                      "Loan Recovery",
                      "-₹${loan.toStringAsFixed(2)}",
                      isDeduction: true,
                    ),
                  if (otherDeductions > 0)
                    _buildSlipItem(
                      "Other Deductions",
                      "-₹${otherDeductions.toStringAsFixed(2)}",
                      isDeduction: true,
                    ),
                  _buildSlipItem(
                    "Total Deductions",
                    "-₹${totalDeductions.toStringAsFixed(2)}",
                    isDeduction: true,
                    isBold: true,
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Net Pay Highlight
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "NET TAKE-HOME PAY",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "₹${netSalary.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
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
                        child: const Text(
                          "Close",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomButton(
                        text: "Print Payslip",
                        icon: Icons.print_outlined,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Simulating printer dispatch... Success.",
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlipItem(
    String label,
    String value, {
    bool isDeduction = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isDeduction ? AppColors.danger : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownProgress(
    String label,
    double amount,
    double total,
    Color color,
  ) {
    final pct = total > 0 ? (amount / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              "₹${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
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
      return const Center(
        child: Text("Please sign in to view payroll ledger."),
      );
    }

    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final controller = Get.isRegistered<CrmController>()
          ? Get.find<CrmController>()
          : null;
      final isLoading = controller?.isLoadingPayroll.value ?? false;
      final error = controller?.payrollError.value;

      // Find the payroll matching this employee in the fetched lists
      final matchingPayroll = controller?.payrolls.firstWhereOrNull(
        (p) =>
            p.employeeId == user.id ||
            p.employeeName.toLowerCase() == user.name.toLowerCase(),
      );

      // Fallback calculation logic:
      final monthlyBase = user.salary / 12;
      final monthlyBonus = (user.performanceRating >= 4.5)
          ? (monthlyBase * 0.12)
          : (monthlyBase * 0.05);
      final taxDeduction = monthlyBase * 0.12;
      final medicalDeduction = 150.00;
      final netTakeHome =
          (monthlyBase + monthlyBonus) - (taxDeduction + medicalDeduction);

      // Selected payroll variables:
      final double baseSalary = matchingPayroll != null
          ? matchingPayroll.basicSalary
          : monthlyBase;

      final double allowancesSum = matchingPayroll != null
          ? (matchingPayroll.hra +
                matchingPayroll.transport +
                matchingPayroll.medical +
                matchingPayroll.special +
                matchingPayroll.otherAllowance)
          : monthlyBonus;

      final double taxSum = matchingPayroll != null
          ? matchingPayroll.tax
          : taxDeduction;
      final double insuranceSum = matchingPayroll != null
          ? matchingPayroll.insurance
          : medicalDeduction;
      final double pfSum = matchingPayroll != null
          ? matchingPayroll.providentFund
          : 0.0;
      final double loanSum = matchingPayroll != null
          ? matchingPayroll.loan
          : 0.0;
      final double otherDecSum = matchingPayroll != null
          ? matchingPayroll.otherDeduction
          : 0.0;

      final double totalEarnings = matchingPayroll != null
          ? matchingPayroll.totalEarnings
          : (baseSalary + allowancesSum);
      final double totalDeductions = matchingPayroll != null
          ? matchingPayroll.totalDeductions
          : (taxSum + insuranceSum + pfSum + loanSum + otherDecSum);
      final double netTakeHomeFinal = matchingPayroll != null
          ? matchingPayroll.netSalary
          : netTakeHome;

      final String status = matchingPayroll != null
          ? matchingPayroll.status
          : "Paid";

      // Build the logs based on controller's payrolls or the fallback single item
      final isManager =
          state.currentRole == UserRole.superAdmin ||
          state.currentRole == UserRole.hr;
      final List<dynamic> payrollList =
          controller != null && controller.payrolls.isNotEmpty
          ? controller.payrolls
          : [matchingPayroll ?? 'fallback'];

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with drop downs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
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
                ),
                // Dropdowns
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedYear,
                          items: _years
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(
                                    y.toString(),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedYear = val;
                              });
                              _fetchPayroll();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedMonth,
                          items: _months.entries
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(
                                    e.value.substring(0, 3),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedMonth = val;
                              });
                              _fetchPayroll();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
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
                            Text(
                              matchingPayroll != null
                                  ? "${matchingPayroll.employeeName}'s Pay Breakdown (${_months[_selectedMonth]} $_selectedYear)"
                                  : "Current Month Pay Breakdown (${_months[_selectedMonth]} $_selectedYear)",
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildBreakdownProgress(
                              "Net Take-Home Pay (Liquid)",
                              netTakeHomeFinal,
                              totalEarnings,
                              AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            _buildBreakdownProgress(
                              "Income Tax Withholding",
                              taxSum,
                              totalEarnings,
                              AppColors.danger,
                            ),
                            const SizedBox(height: 16),
                            _buildBreakdownProgress(
                              "Medical Insurance Premium",
                              insuranceSum,
                              totalEarnings,
                              AppColors.warning,
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: AppColors.border),
                            const SizedBox(height: 16),
                            width < 600
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Net Paid Amount",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "₹${netTakeHomeFinal.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: CustomButton(
                                          text: "View Payslip Receipt",
                                          icon: Icons.receipt_long,
                                          onPressed: () => _showPayslipDialog(
                                            context: context,
                                            month:
                                                "${_months[_selectedMonth]} $_selectedYear",
                                            basePay: baseSalary,
                                            hra: matchingPayroll?.hra ?? 0.0,
                                            transport:
                                                matchingPayroll?.transport ??
                                                0.0,
                                            medical:
                                                matchingPayroll?.medical ?? 0.0,
                                            special:
                                                matchingPayroll?.special ?? 0.0,
                                            otherAllowance:
                                                matchingPayroll
                                                    ?.otherAllowance ??
                                                0.0,
                                            tax: taxSum,
                                            pf: pfSum,
                                            insurance: insuranceSum,
                                            loan: loanSum,
                                            otherDeductions: otherDecSum,
                                            totalEarnings: totalEarnings,
                                            totalDeductions: totalDeductions,
                                            netSalary: netTakeHomeFinal,
                                            employeeName:
                                                matchingPayroll?.employeeName ??
                                                user.name,
                                            status: status,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Net Paid Amount",
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "₹${netTakeHomeFinal.toStringAsFixed(2)}",
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      CustomButton(
                                        text: "View Payslip Receipt",
                                        icon: Icons.receipt_long,
                                        onPressed: () => _showPayslipDialog(
                                          context: context,
                                          month:
                                              "${_months[_selectedMonth]} $_selectedYear",
                                          basePay: baseSalary,
                                          hra: matchingPayroll?.hra ?? 0.0,
                                          transport:
                                              matchingPayroll?.transport ?? 0.0,
                                          medical:
                                              matchingPayroll?.medical ?? 0.0,
                                          special:
                                              matchingPayroll?.special ?? 0.0,
                                          otherAllowance:
                                              matchingPayroll?.otherAllowance ??
                                              0.0,
                                          tax: taxSum,
                                          pf: pfSum,
                                          insurance: insuranceSum,
                                          loan: loanSum,
                                          otherDeductions: otherDecSum,
                                          totalEarnings: totalEarnings,
                                          totalDeductions: totalDeductions,
                                          netSalary: netTakeHomeFinal,
                                          employeeName:
                                              matchingPayroll?.employeeName ??
                                              user.name,
                                          status: status,
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
                            Text(
                              isManager
                                  ? "Employee Payroll Records"
                                  : "My Payslip Record Log",
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            else if (error != null)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Text(
                                    "Error loading payrolls: $error",
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                              )
                            else if (payrollList.isEmpty ||
                                (payrollList.length == 1 &&
                                    payrollList[0] == 'fallback' &&
                                    matchingPayroll == null &&
                                    isManager))
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                    "No records found for this period.",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: payrollList.length,
                                separatorBuilder: (context, idx) =>
                                    const Divider(
                                      color: AppColors.border,
                                      height: 1,
                                    ),
                                itemBuilder: (context, idx) {
                                  final item = payrollList[idx];

                                  if (item == 'fallback') {
                                    // Fallback employee representation
                                    final mthStr =
                                        "${_months[_selectedMonth]} $_selectedYear";
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.picture_as_pdf_outlined,
                                                  color: AppColors.danger,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Payslip_${user.name}_$mthStr.pdf",
                                                        style: const TextStyle(
                                                          color: AppColors
                                                              .textPrimary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        "Employee: ${user.name} • Status: Fallback",
                                                        style: const TextStyle(
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontSize: 11,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                              context: context,
                                              month: mthStr,
                                              basePay: baseSalary,
                                              hra: 0.0,
                                              transport: 0.0,
                                              medical: 0.0,
                                              special: 0.0,
                                              otherAllowance: 0.0,
                                              tax: taxSum,
                                              pf: pfSum,
                                              insurance: insuranceSum,
                                              loan: loanSum,
                                              otherDeductions: otherDecSum,
                                              totalEarnings: totalEarnings,
                                              totalDeductions: totalDeductions,
                                              netSalary: netTakeHomeFinal,
                                              employeeName: user.name,
                                              status: status,
                                            ),
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              minimumSize: const Size(60, 32),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text(
                                              "Open Slip",
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final CRMPayroll p = item as CRMPayroll;
                                  final mthStr =
                                      "${_months[p.month]} ${p.year}";
                                  final double pBase = p.basicSalary;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.picture_as_pdf_outlined,
                                                color: AppColors.danger,
                                                size: 22,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Payslip_${p.employeeName}_$mthStr.pdf",
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .textPrimary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      "Employee: ${p.employeeName} • Net: ₹${p.netSalary.toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                        fontSize: 11,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                            context: context,
                                            month: mthStr,
                                            basePay: pBase,
                                            hra: p.hra,
                                            transport: p.transport,
                                            medical: p.medical,
                                            special: p.special,
                                            otherAllowance: p.otherAllowance,
                                            tax: p.tax,
                                            pf: p.providentFund,
                                            insurance: p.insurance,
                                            loan: p.loan,
                                            otherDeductions: p.otherDeduction,
                                            totalEarnings: p.totalEarnings,
                                            totalDeductions: p.totalDeductions,
                                            netSalary: p.netSalary,
                                            employeeName: p.employeeName,
                                            status: p.status,
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            minimumSize: const Size(60, 32),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text(
                                            "Open Slip",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
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
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPolicyItem(
                            "Federal Tax Deduction",
                            "Standard 12% applied automatically to monthly gross wages.",
                          ),
                          _buildPolicyItem(
                            "Performance Accrual",
                            "Up to 12% bonuses granted for Q1/Q2/Q3/Q4 KPI score cards above 4.5.",
                          ),
                          _buildPolicyItem(
                            "Healthcare Contributions",
                            "Includes Dental, Medical and Life insurance coverages.",
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
}
