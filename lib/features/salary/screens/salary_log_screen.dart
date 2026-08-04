import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SalaryLogScreen extends StatelessWidget {
  const SalaryLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salary Overview',
                style: AppTypography.headlineMedium(),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 100),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work_history_outlined,
                      size: 80,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Salary Module Coming Soon',
                      style: AppTypography.titleMedium(color: AppColors.secondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your real paychecks and deductions here.',
                      style: AppTypography.bodyMedium(color: AppColors.secondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
