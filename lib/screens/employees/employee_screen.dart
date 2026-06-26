import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/crm_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/employee.dart';
import '../../services/mock_data_service.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEmployeeDialog(BuildContext context, MockDataService state) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white,
          title: const Text(
            "Add New Employee",
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
                children: [
                  CustomTextField(
                    label: "Full Name",
                    hint: "e.g., Jane Smith",
                    prefixIcon: Icons.person_outline,
                    controller: nameCtrl,
                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: "Email Address",
                    hint: "username@company.com",
                    prefixIcon: Icons.email_outlined,
                    controller: emailCtrl,
                    validator: (val) => val == null || !val.contains('@') ? "Valid email required" : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: "Role",
                          hint: "Software Eng",
                          prefixIcon: Icons.work_outline,
                          controller: roleCtrl,
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: "Department",
                          hint: "Engineering",
                          prefixIcon: Icons.business_outlined,
                          controller: deptCtrl,
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: "Salary (Annual)",
                          hint: "e.g., 90000",
                          prefixIcon: Icons.payments_outlined,
                          controller: salaryCtrl,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || double.tryParse(val) == null ? "Valid number required" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: "Phone",
                          hint: "+1 555-0100",
                          prefixIcon: Icons.phone_outlined,
                          controller: phoneCtrl,
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
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
              text: "Board Employee",
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newEmp = Employee(
                    id: "EMP-0${state.employees.length + 1}",
                    name: nameCtrl.text,
                    email: emailCtrl.text,
                    role: roleCtrl.text,
                    department: deptCtrl.text,
                    status: "Active",
                    salary: double.parse(salaryCtrl.text),
                    performanceRating: 5.0, // Default start rating
                    dateJoined: DateTime.now().toString().split(' ')[0],
                    phone: phoneCtrl.text,
                    avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
                  );
                  state.addEmployee(newEmp);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEmployeeDetails(BuildContext context, Employee emp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.badge_outlined, color: AppColors.primary, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              emp.employeeId.isNotEmpty ? emp.employeeId : emp.id,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emp.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${emp.designation ?? (emp.role.isNotEmpty ? emp.role[0].toUpperCase() + emp.role.substring(1) : '')} • ${emp.department}",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: emp.status == 'Active'
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                emp.status,
                                style: TextStyle(
                                  color: emp.status == 'Active'
                                      ? AppColors.primary
                                      : Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Contact details",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.email_outlined, "Email address", emp.email),
                  _buildDetailRow(Icons.phone_outlined, "Mobile phone", emp.phone),
                  const SizedBox(height: 24),
                  const Text(
                    "Employment details",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.calendar_month_outlined, "Date Joined", emp.dateJoined),
                  _buildDetailRow(Icons.payments_outlined, "Compensation", "\$${emp.salary.toStringAsFixed(0)} / yr"),
                  _buildDetailRow(
                    Icons.star_border_outlined,
                    "KPI rating",
                    "${emp.performanceRating} / 5.0",
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < emp.performanceRating.floor() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
    final width = MediaQuery.of(context).size.width;

    return Obx(() {
      final controller = Get.isRegistered<CrmController>() ? Get.find<CrmController>() : null;
      final isLoading = controller?.isLoadingEmployees.value ?? false;
      final error = controller?.employeesError.value;

      final filteredList = state.employees.where((e) {
        return e.name.toLowerCase().contains(_searchQuery) ||
            e.role.toLowerCase().contains(_searchQuery) ||
            (e.designation?.toLowerCase().contains(_searchQuery) ?? false) ||
            e.department.toLowerCase().contains(_searchQuery);
      }).toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Add Employee Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Employee Directory",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Manage directory profiles, roles, salaries, and details.",
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
                  text: "Add Employee",
                  icon: Icons.add,
                  onPressed: () => _showAddEmployeeDialog(context, state),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Input Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Search by employee name, role, department...",
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Responsive List/Table representation
            Container(
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
              child: isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    )
                  : error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              "Error loading employees: $error",
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ),
                        )
                      : filteredList.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text("No employees found.", style: TextStyle(color: AppColors.textSecondary)),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredList.length,
                              separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                              itemBuilder: (context, index) {
                                final emp = filteredList[index];

                                return InkWell(
                                  onTap: () => _showEmployeeDetails(context, emp),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    child: Row(
                                      children: [
                                         Container(
                                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                           decoration: BoxDecoration(
                                             color: AppColors.primary.withOpacity(0.08),
                                             borderRadius: BorderRadius.circular(6),
                                             border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                                           ),
                                           child: Text(
                                             emp.employeeId.isNotEmpty ? emp.employeeId : emp.id,
                                             style: const TextStyle(
                                               color: AppColors.primary,
                                               fontSize: 11,
                                               fontWeight: FontWeight.bold,
                                               letterSpacing: 0.3,
                                             ),
                                           ),
                                         ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                emp.name,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                emp.email,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (width > 600) ...[
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              emp.designation ?? (emp.role.isNotEmpty ? emp.role[0].toUpperCase() + emp.role.substring(1) : ''),
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              emp.department,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: emp.status == 'Active'
                                                ? AppColors.primary.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            emp.status,
                                            style: TextStyle(
                                              color: emp.status == 'Active'
                                                  ? AppColors.primary
                                                  : Colors.grey[600],
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: AppColors.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      );
    });
  }
}
