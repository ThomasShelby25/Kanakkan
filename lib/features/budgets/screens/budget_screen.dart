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
      if (tx.type == TransactionType.expense &&
          tx.date.month == now.month &&
          tx.date.year == now.year) {
        totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
      }
    }
    return totals;
  }

  void _showSetBudgetDialog(
      BuildContext context, String category, double currentLimit) {
    final ctrl = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('$category limit', style: AppTypography.titleMedium()),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: AppTypography.bodyMedium(),
            decoration: InputDecoration(
              labelText: 'Monthly limit (₹)',
              labelStyle: TextStyle(color: AppColors.secondary),
              prefixIcon:
                  Icon(Icons.currency_rupee, color: AppColors.secondary, size: 18),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  Text('Cancel', style: TextStyle(color: AppColors.secondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final amount = double.tryParse(ctrl.text) ?? 0.0;
                final provider =
                    Provider.of<FinanceProvider>(context, listen: false);
                await provider.setBudget(category, amount);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Set limit'),
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_rounded,
                        color: AppColors.onSurface, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Text('Budgets', style: AppTypography.headlineMedium()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 0, 20, 20),
              child: Text(
                'Tap any row to set a monthly limit',
                style: AppTypography.labelSmall(color: AppColors.secondary),
              ),
            ),

            Divider(height: 1, color: AppColors.outline),

            // ── Ledger rows ─────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                itemCount: _allCategories.length,
                itemBuilder: (context, index) {
                  final cat = _allCategories[index];
                  final catName = cat['name'] as String;

                  final spent = spentTotals[catName] ?? 0.0;
                  final budgetOpt = provider.budgets
                      .where((b) => b.category == catName);
                  final limit =
                      budgetOpt.isNotEmpty ? budgetOpt.first.limitAmount : 0.0;

                  final hasBudget = limit > 0;
                  final progress =
                      hasBudget ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                  final isOverBudget = hasBudget && spent > limit;

                  Color progressColor = AppColors.onSurface.withValues(alpha: 0.7);
                  if (progress > 0.8 && !isOverBudget) progressColor = Colors.orange;
                  if (isOverBudget) progressColor = AppColors.error;

                  return InkWell(
                    onTap: () => _showSetBudgetDialog(context, catName, limit),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.outline, width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  catName,
                                  style: AppTypography.bodyMedium()
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              // Spent amount
                              Text(
                                '₹${spent.toStringAsFixed(0)}',
                                style: AppTypography.amountSmall(
                                  color: isOverBudget
                                      ? AppColors.error
                                      : AppColors.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                              if (hasBudget) ...[
                                Text(
                                  ' / ₹${limit.toStringAsFixed(0)}',
                                  style: AppTypography.amountSmall(
                                    color: AppColors.secondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (hasBudget) ...[
                            const SizedBox(height: 10),
                            // Thin progress bar — no rounded clip, raw ledger feel
                            Stack(
                              children: [
                                Container(
                                  height: 2,
                                  color: AppColors.outline,
                                ),
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    height: 2,
                                    color: progressColor,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 4),
                            Text(
                              'Tap to set limit',
                              style: AppTypography.labelSmall(color: AppColors.secondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
