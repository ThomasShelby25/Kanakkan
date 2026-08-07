import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/transaction.dart';


class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final List<Map<String, dynamic>> _allCategories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Transport', 'icon': Icons.directions_car},
    {'name': 'Entertainment', 'icon': Icons.theater_comedy},
    {'name': 'General', 'icon': Icons.category},
  ];

  Map<String, double> _calculateSpent(List<TransactionModel> txs) {
    Map<String, double> totals = {};
    final now = DateTime.now();
    for (var tx in txs) {
      if (tx.type == TransactionType.expense && tx.date.month == now.month && tx.date.year == now.year) {
        totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
      }
    }
    return totals;
  }

  void _showSetBudgetDialog(BuildContext context, String category, double currentLimit) {
    final ctrl = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Set $category Budget', style: AppTypography.titleMedium()),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: AppTypography.bodyMedium(),
            decoration: InputDecoration(
              labelText: 'Monthly Limit (₹)',
              labelStyle: TextStyle(color: AppColors.secondary),
              prefixIcon: Icon(Icons.currency_rupee, color: AppColors.secondary, size: 18),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppColors.secondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final amount = double.tryParse(ctrl.text) ?? 0.0;
                final provider = Provider.of<FinanceProvider>(context, listen: false);
                await provider.setBudget(category, amount);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final spentTotals = _calculateSpent(provider.validTransactions);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Budgets & Goals', style: AppTypography.titleMedium()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _allCategories.length,
        itemBuilder: (context, index) {
          final cat = _allCategories[index];
          final catName = cat['name'] as String;
          final icon = cat['icon'] as IconData;
          
          final spent = spentTotals[catName] ?? 0.0;
          
          // Find budget limit if exists
          final budgetOpt = provider.budgets.where((b) => b.category == catName);
          final limit = budgetOpt.isNotEmpty ? budgetOpt.first.limitAmount : 0.0;
          
          final hasBudget = limit > 0;
          final progress = hasBudget ? (spent / limit).clamp(0.0, 1.0) : 0.0;
          final isOverBudget = hasBudget && spent > limit;
          
          Color progressColor = AppColors.primary;
          if (progress > 0.8 && !isOverBudget) progressColor = Colors.orange;
          if (isOverBudget) progressColor = Colors.redAccent;

          return GestureDetector(
            onTap: () => _showSetBudgetDialog(context, catName, limit),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOverBudget ? Colors.redAccent.withValues(alpha: 0.5) : AppColors.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(catName, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.bold)),
                            if (hasBudget)
                              Text(
                                isOverBudget ? 'Over Budget!' : '${(progress * 100).toStringAsFixed(0)}% Used',
                                style: AppTypography.labelSmall(
                                  color: isOverBudget ? Colors.redAccent : AppColors.secondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${spent.toStringAsFixed(0)}', style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            hasBudget ? 'of ₹${limit.toStringAsFixed(0)}' : 'No limit set',
                            style: AppTypography.labelSmall(color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (hasBudget) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
