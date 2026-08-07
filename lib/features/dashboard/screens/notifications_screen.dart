import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final budgets = provider.budgets;
    
    List<Map<String, dynamic>> alerts = [];
    
    for (var budget in budgets) {
      final spent = provider.getCategoryExpense(budget.category);
      if (budget.limitAmount > 0) {
        final percent = (spent / budget.limitAmount) * 100;
        if (percent >= 100) {
          alerts.add({
            'title': 'Budget Exceeded',
            'message': 'You have exceeded your ${budget.category} budget by ₹${(spent - budget.limitAmount).toStringAsFixed(0)}.',
            'isCritical': true,
            'time': 'Just now',
          });
        } else if (percent >= 80) {
          alerts.add({
            'title': 'Budget Warning',
            'message': 'You have used ${percent.toStringAsFixed(0)}% of your ${budget.category} budget.',
            'isCritical': false,
            'time': 'Today',
          });
        }
      }
    }
    
    // Add a system welcome message if empty
    if (alerts.isEmpty) {
      alerts.add({
        'title': 'System Active',
        'message': 'All budgets are healthy. KANAKKAN is silently monitoring your transactions.',
        'isCritical': false,
        'time': 'System',
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.onSurface),
        title: Text('Notifications', style: AppTypography.titleMedium()),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          final isCritical = alert['isCritical'] as bool;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isCritical ? AppColors.error : AppColors.outline),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
                  color: isCritical ? AppColors.error : AppColors.secondary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(alert['title'], style: AppTypography.titleMedium(color: isCritical ? AppColors.error : AppColors.onSurface)),
                          Text(alert['time'], style: AppTypography.labelSmall(color: AppColors.secondary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(alert['message'], style: AppTypography.bodyMedium(color: AppColors.secondary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
