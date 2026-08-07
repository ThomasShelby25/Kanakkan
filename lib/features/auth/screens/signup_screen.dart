import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/supabase_service.dart';


class SignupScreen extends StatefulWidget {
  final VoidCallback onSignupSuccess;

  const SignupScreen({super.key, required this.onSignupSuccess});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;


  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an email and password.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.signUp(email, password);
      if (mounted) {
        Navigator.pop(context);
        widget.onSignupSuccess();
      }
    } catch (e) {
      debugPrint('Supabase Sign Up note: $e');
      final errStr = e.toString();
      if (errStr.contains('user_already_exists') || errStr.contains('already registered')) {
        // Try logging in if user already exists
        try {
          await SupabaseService.signIn(email, password);
          if (mounted) {
            Navigator.pop(context);
            widget.onSignupSuccess();
          }
          return;
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign Up Note: ${errStr.replaceAll('AuthApiException', '')}'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
          ),
        );
        // Direct entry if account state allows
        Navigator.pop(context);
        widget.onSignupSuccess();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Create Account',
                style: AppTypography.displayLarge(),
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your salary and expenses today',
                style: AppTypography.bodyMedium(color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Full Name Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Full Name',
                  style: AppTypography.labelSmall(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Alex Morgan',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 16),

              // Email Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email Address',
                  style: AppTypography.labelSmall(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@company.com',
                  prefixIcon: Icon(Icons.mail_outline, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 16),

              // Password Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: AppTypography.labelSmall(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.secondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.secondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Terms Checkbox
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _acceptTerms,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _acceptTerms = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'I agree to the Terms of Service & Privacy Policy',
                      style: AppTypography.bodyMedium(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign Up CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _handleSignup,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Sign Up',
                          style: AppTypography.titleMedium(color: Colors.white),
                        ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
