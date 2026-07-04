import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services/mock_data_service.dart';
import '../main_layout.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController(text: "Product Analyst");
  final _deptController = TextEditingController(text: "Product Development");
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      MockDataService().signup(
        _nameController.text,
        _emailController.text,
        _roleController.text,
        _deptController.text,
        _phoneController.text,
      );

      // Successfully registered and logged in, push to Dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainLayout()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _deptController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: Container(
              width: isDesktop ? 480 : double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Create Corporate Account",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Join the RidealCRM team ecosystem.",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: "Full Name",
                      hint: "Enter your first and last name",
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      validator: (val) => val == null || val.isEmpty
                          ? "Name is required"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "Corporate Email Address",
                      hint: "username@company.com",
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return "Email is required";
                        if (!val.contains('@'))
                          return "Enter a valid corporate email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: "Role",
                            hint: "Designation",
                            prefixIcon: Icons.work_outline,
                            controller: _roleController,
                            validator: (val) =>
                                val == null || val.isEmpty ? "Required" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: "Department",
                            hint: "Department name",
                            prefixIcon: Icons.business_outlined,
                            controller: _deptController,
                            validator: (val) =>
                                val == null || val.isEmpty ? "Required" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "Contact Number",
                      hint: "+1 (555) 000-0000",
                      prefixIcon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty
                          ? "Phone is required"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "Password",
                      hint: "Create security password",
                      prefixIcon: Icons.lock_outline,
                      controller: _passController,
                      isPassword: true,
                      validator: (val) => val == null || val.length < 6
                          ? "Must be 6+ chars"
                          : null,
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      width: double.infinity,
                      text: "Register & Connect",
                      onPressed: _handleSignup,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
