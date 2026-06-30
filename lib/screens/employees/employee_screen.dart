import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    final phoneCtrl = TextEditingController();
    final joiningDateCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    final desigCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    String selectedRole = 'Employee';
    String selectedDept = 'Engineering';
    bool showPassword = false;

    final rolesList = [
      'Super admin',
      'Admin',
      'Hr manager',
      'HR',
      'Manager',
      'software engineer',
      'bussiness development executive',
      'Employee'
    ];
    final deptsList = [
      'Customer service',
      'Customer Success',
      'IT support',
      'Engineering',
      'Sales',
      'Marketing',
      'HR',
      'Finance',
      'operation',
      'Operations'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildSectionHeader(String title, IconData icon) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            Widget buildDropdown({
              required String label,
              required String value,
              required List<String> items,
              required void Function(String?) onChanged,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 1.5),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value,
                        isExpanded: true,
                        items: items.map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item, style: const TextStyle(fontSize: 14)),
                        )).toList(),
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ],
              );
            }

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
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSectionHeader("Basic Information", Icons.person_outline),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: "Full Name *",
                          hint: "John Doe",
                          prefixIcon: Icons.person_outline,
                          controller: nameCtrl,
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "Email Address *",
                          hint: "john.doe@company.com",
                          prefixIcon: Icons.email_outlined,
                          controller: emailCtrl,
                          validator: (val) => val == null || !val.contains('@') ? "Valid email required" : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: "Phone *",
                                hint: "+1 234-567-8900",
                                prefixIcon: Icons.phone_outlined,
                                controller: phoneCtrl,
                                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Date of Joining *",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: joiningDateCtrl,
                                    readOnly: true,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "e.g., 2026-06-29",
                                      hintStyle: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20,
                                        color: AppColors.textSecondary,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.danger, width: 2),
                                      ),
                                    ),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setDialogState(() {
                                          joiningDateCtrl.text = picked.toString().split(' ')[0];
                                        });
                                      }
                                    },
                                    validator: (val) => val == null || val.isEmpty ? "Required" : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.border),
                        buildSectionHeader("Role & Department", Icons.work_outline),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: buildDropdown(
                                label: "Role *",
                                value: selectedRole,
                                items: rolesList,
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => selectedRole = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildDropdown(
                                label: "Department *",
                                value: selectedDept,
                                items: deptsList,
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => selectedDept = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "Designation *",
                          hint: "e.g., Sales Executive",
                          prefixIcon: Icons.badge_outlined,
                          controller: desigCtrl,
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.border),
                        buildSectionHeader("Compensation", Icons.payments_outlined),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: "Annual Salary (USD) *",
                          hint: "e.g., 50000",
                          prefixIcon: Icons.payments_outlined,
                          controller: salaryCtrl,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || double.tryParse(val) == null ? "Valid salary required" : null,
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.border),
                        buildSectionHeader("Security", Icons.lock_outline),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: "Password *",
                                hint: "Min 6 characters",
                                prefixIcon: Icons.lock_outline,
                                controller: passCtrl,
                                isPassword: true,
                                validator: (val) => val == null || val.length < 6 ? "Min 6 chars required" : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: "Confirm Password *",
                                hint: "Verify password",
                                prefixIcon: Icons.lock_outline,
                                controller: confirmPassCtrl,
                                isPassword: true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return "Required";
                                  if (val != passCtrl.text) return "Passwords do not match";
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                        role: selectedRole.toLowerCase(),
                        designation: desigCtrl.text,
                        department: selectedDept,
                        status: "Active",
                        salary: double.parse(salaryCtrl.text),
                        performanceRating: 5.0,
                        dateJoined: joiningDateCtrl.text,
                        phone: phoneCtrl.text,
                        avatarUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150",
                        password: passCtrl.text,
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
      },
    );
  }

  void _showEditEmployeeDialog(BuildContext context, Employee emp, MockDataService state) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: emp.name);
    final phoneCtrl = TextEditingController(text: emp.phone);
    final desigCtrl = TextEditingController(text: emp.designation ?? '');
    final salaryCtrl = TextEditingController(text: emp.salary.toStringAsFixed(0));

    final rolesList = [
      'Super admin',
      'Admin',
      'Hr manager',
      'HR',
      'Manager',
      'software engineer',
      'bussiness development executive',
      'Employee'
    ];
    final deptsList = [
      'Customer service',
      'Customer Success',
      'IT support',
      'Engineering',
      'Sales',
      'Marketing',
      'HR',
      'Finance',
      'operation',
      'Operations'
    ];
    final statusList = ['Active', 'Inactive', 'On-leave', 'Terminated'];

    String selectedRole = 'Employee';
    for (var r in rolesList) {
      if (r.toLowerCase() == emp.role.toLowerCase()) {
        selectedRole = r;
        break;
      }
    }

    String selectedDept = 'Engineering';
    for (var d in deptsList) {
      if (d.toLowerCase() == emp.department.toLowerCase()) {
        selectedDept = d;
        break;
      }
    }

    String selectedStatus = 'Active';
    for (var s in statusList) {
      if (s.toLowerCase() == emp.status.toLowerCase()) {
        selectedStatus = s;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildSectionHeader(String title, IconData icon) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            Widget buildDropdown({
              required String label,
              required String value,
              required List<String> items,
              required void Function(String?) onChanged,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 1.5),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value,
                        isExpanded: true,
                        items: items.map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item, style: const TextStyle(fontSize: 14)),
                        )).toList(),
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ],
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              title: const Text(
                "Edit Employee Details",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSectionHeader("Personal Details", Icons.person_outline),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: "Full Name *",
                          hint: "John Doe",
                          prefixIcon: Icons.person_outline,
                          controller: nameCtrl,
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: "Phone *",
                                hint: "+1 234-567-8900",
                                prefixIcon: Icons.phone_outlined,
                                controller: phoneCtrl,
                                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildDropdown(
                                label: "Status *",
                                value: selectedStatus,
                                items: statusList,
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => selectedStatus = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.border),
                        buildSectionHeader("Role & Department", Icons.work_outline),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: buildDropdown(
                                label: "Role *",
                                value: selectedRole,
                                items: rolesList,
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => selectedRole = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildDropdown(
                                label: "Department *",
                                value: selectedDept,
                                items: deptsList,
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => selectedDept = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: "Designation *",
                          hint: "e.g., Sales Executive",
                          prefixIcon: Icons.badge_outlined,
                          controller: desigCtrl,
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.border),
                        buildSectionHeader("Compensation", Icons.payments_outlined),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: "Annual Salary (USD) *",
                          hint: "e.g., 50000",
                          prefixIcon: Icons.payments_outlined,
                          controller: salaryCtrl,
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || double.tryParse(val) == null ? "Valid salary required" : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
                ),
                CustomButton(
                  text: "Save Changes",
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final updatedEmp = emp.copyWith(
                        name: nameCtrl.text,
                        phone: phoneCtrl.text,
                        role: selectedRole.toLowerCase(),
                        designation: desigCtrl.text,
                        department: selectedDept,
                        salary: double.parse(salaryCtrl.text),
                        status: selectedStatus,
                      );
                      final success = await state.updateEmployee(updatedEmp);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Employee updated successfully!")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to update employee.")),
                          );
                        }
                      }
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

  void _confirmDeleteEmployee(BuildContext context, Employee emp, MockDataService state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete the employee record for ${emp.name}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await state.deleteEmployee(emp.id);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Employee deleted successfully!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to delete employee.")),
                    );
                  }
                }
              },
              child: const Text("Delete", style: TextStyle(color: AppColors.danger)),
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
                  _buildDetailRow(Icons.payments_outlined, "Compensation", "₹${emp.salary.toStringAsFixed(0)} / yr"),
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
                          : AnimationLimiter(
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredList.length,
                                separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
                                itemBuilder: (context, index) {
                                  final emp = filteredList[index];

                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: InkWell(
                                          onTap: () => _showEmployeeDetails(context, emp),
                                          child: width <= 600
                                              ? Padding(
                                                  padding: const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Expanded(
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
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                                const SizedBox(height: 2),
                                                                Text(
                                                                  emp.designation ?? (emp.role.isNotEmpty ? emp.role[0].toUpperCase() + emp.role.substring(1) : ''),
                                                                  style: const TextStyle(
                                                                    color: AppColors.textSecondary,
                                                                    fontSize: 12,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 12),
                                                      const Divider(height: 1, color: AppColors.border),
                                                      const SizedBox(height: 12),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  emp.email,
                                                                  style: const TextStyle(
                                                                    color: AppColors.textSecondary,
                                                                    fontSize: 11,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                                      decoration: BoxDecoration(
                                                                        color: AppColors.primary.withOpacity(0.08),
                                                                        borderRadius: BorderRadius.circular(4),
                                                                        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                                                                      ),
                                                                      child: Text(
                                                                        emp.employeeId.isNotEmpty ? emp.employeeId : emp.id,
                                                                        style: const TextStyle(
                                                                          color: AppColors.primary,
                                                                          fontSize: 9,
                                                                          fontWeight: FontWeight.bold,
                                                                          letterSpacing: 0.3,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 8),
                                                                    Text(
                                                                      emp.department,
                                                                      style: const TextStyle(
                                                                        color: AppColors.textSecondary,
                                                                        fontSize: 11,
                                                                        fontWeight: FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12),
                                                          Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              IconButton(
                                                                icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
                                                                onPressed: () => _showEditEmployeeDialog(context, emp, state),
                                                                constraints: const BoxConstraints(),
                                                                padding: const EdgeInsets.all(6),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              IconButton(
                                                                icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                                                                onPressed: () => _confirmDeleteEmployee(context, emp, state),
                                                                constraints: const BoxConstraints(),
                                                                padding: const EdgeInsets.all(6),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Padding(
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
                                                      IconButton(
                                                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                                        onPressed: () => _showEditEmployeeDialog(context, emp, state),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                                                        onPressed: () => _confirmDeleteEmployee(context, emp, state),
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
    });
  }
}
