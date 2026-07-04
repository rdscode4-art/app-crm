import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services/mock_data_service.dart';
import '../main_layout.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final error = await MockDataService().login(
          _emailController.text,
          _passwordController.text,
        );

        if (error == null) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MainLayout(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        } else {
          if (!mounted) return;
          setState(() {
            _errorMessage = error;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              width: isDesktop ? 450 : double.infinity,
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
                    // Brand Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/rdslogo.jpeg',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        "Sign in to your portal",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // const SizedBox(height: 8),
                    // const Center(
                    //   child: Text(
                    //     "Use admin@crm.com to access HR administration panel",
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       color: AppColors.textSecondary,
                    //       fontSize: 13,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 24),

                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    CustomTextField(
                      label: "Corporate Email Address",
                      hint: "Enter your email address",
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Email is required";
                        }
                        if (!val.contains('@')) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "Password",
                      hint: "Enter your password",
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Password is required";
                        }
                        if (val.length < 4) {
                          return "Password must be at least 4 characters";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 12),

                    CustomButton(
                      width: double.infinity,
                      text: "Sign In",
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),

                    // Redirect to Signup
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     const Text(
                    //       "Don't have an account?",
                    //       style: TextStyle(
                    //         color: AppColors.textSecondary,
                    //         fontSize: 13,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 4),
                    //     GestureDetector(
                    //       onTap: () {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (context) => const SignupScreen(),
                    //           ),
                    //         );
                    //       },
                    //       child: const Text(
                    //         "Sign Up",
                    //         style: TextStyle(
                    //           color: AppColors.primary,
                    //           fontSize: 13,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    //),
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
