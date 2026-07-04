import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services/mock_data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _emailNotifs = true;
  bool _directReportsAlerts = false;
  bool _twoFactor = true;

  @override
  void initState() {
    super.initState();
    final state = MockDataService();
    _nameController = TextEditingController(
      text: state.currentUser?.name ?? "",
    );
    _phoneController = TextEditingController(
      text: state.currentUser?.phone ?? "",
    );
    _emailController = TextEditingController(
      text: state.currentUser?.email ?? "",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile(MockDataService state) {
    if (_formKey.currentState!.validate() && state.currentUser != null) {
      final updated = state.currentUser!.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );
      state.updateEmployee(updated);
      state.addNotification(
        "Profile Updated",
        "Your contact and name details have been saved.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile settings successfully saved.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = MockDataService();
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
                "Profile",

                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              // Text(
              //   "Customize notification alerts, workspace databases, and security options.",
              //   style: TextStyle(
              //     color: AppColors.textSecondary,
              //     fontSize: 14,
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 24),

          // Settings forms (responsive)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left profile and configurations cards
              Expanded(
                flex: width < 1000 ? 1 : 2,
                child: Column(
                  children: [
                    // Profile Editor Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Personal Workspace Profile",
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 36,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.currentUser?.name ?? "Employee",
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      state.currentUser?.designation ??
                                          (state.currentUser?.role.isNotEmpty ==
                                                  true
                                              ? state.currentUser!.role[0]
                                                        .toUpperCase() +
                                                    state.currentUser!.role
                                                        .substring(1)
                                              : "Employee"),
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              label: "Your Full Name",
                              hint: "Full name",
                              prefixIcon: Icons.person_outline,
                              controller: _nameController,
                              validator: (val) => val == null || val.isEmpty
                                  ? "Required"
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: "Workspace Email Address",
                              hint: "email@company.com",
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              validator: (val) =>
                                  val == null || !val.contains('@')
                                  ? "Invalid email"
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: "Contact Number",
                              hint: "+1 555-0100",
                              prefixIcon: Icons.phone_outlined,
                              controller: _phoneController,
                              validator: (val) => val == null || val.isEmpty
                                  ? "Required"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: AppColors.border),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CustomButton(
                                text: "Save Profile Changes",
                                onPressed: () => _saveProfile(state),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Configurations Toggles
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
                            "Workspace Notifications & Safety",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchItem(
                            "Email Notification Reports",
                            "Receive daily summaries of sales leads and checkin sheets.",
                            _emailNotifs,
                            (val) => setState(() => _emailNotifs = val),
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          _buildSwitchItem(
                            "Direct Reports Leave Alerts",
                            "Get instant push alerts when team members request casual leaves.",
                            _directReportsAlerts,
                            (val) => setState(() => _directReportsAlerts = val),
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          _buildSwitchItem(
                            "Two-Factor Authentication (2FA)",
                            "Require secure confirmation codes when logging into CRM accounts.",
                            _twoFactor,
                            (val) => setState(() => _twoFactor = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Danger Zone Reset Options (Right panel on desktop)
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
                          "System Diagnostics",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Troubleshooting & Workspace Data Controls",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Restoring defaults will reset the CRM database simulator back to pre-filled configurations, signing you out.",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          width: double.infinity,
                          text: "Reset CRM Database",
                          icon: Icons.delete_forever_outlined,
                          isSecondary: true,
                          onPressed: () {
                            // Diagnostics reset
                            state.logout();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          },
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
  }

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    bool current,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: current,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }
}
