import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/transaction.dart';
import '../../budgets/screens/wallet_manager_screen.dart';



class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinanceProvider>(context, listen: false).loadRealTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Hero Net Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CURRENT NET BALANCE',
                          style: AppTypography.labelCaps(color: AppColors.secondary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+12.4%',
                                style: AppTypography.amountSmall(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${financeProvider.netBalance.toStringAsFixed(2)}',
                      style: AppTypography.amountLarge(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            3,
                            (index) => Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: index == 2
                                    ? AppColors.primary
                                    : AppColors.primary.withValues(alpha: 0.3 * (index + 1)),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Across ${financeProvider.wallets.length} accounts',
                          style: AppTypography.labelSmall(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dual Income / Expense Stat Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.onSurface.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.south_west_rounded,
                                  size: 16,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'INCOME',
                                style: AppTypography.labelCaps(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+₹${financeProvider.totalIncome.toStringAsFixed(2)}',
                            style: AppTypography.titleMedium(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.north_east_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'EXPENSE',
                                style: AppTypography.labelCaps(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '-₹${financeProvider.totalExpense.toStringAsFixed(2)}',
                            style: AppTypography.titleMedium(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Wallets Grid Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wallets',
                    style: AppTypography.titleMedium(),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WalletManagerScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'View All',
                      style: AppTypography.labelSmall(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Wallets Cards
              Row(
                children: financeProvider.wallets.map((wallet) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: wallet.isDark ? AppColors.darkSurface : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: wallet.isDark
                            ? null
                            : Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            wallet.icon,
                            color: wallet.isDark
                                ? Colors.white70
                                : AppColors.secondary,
                            size: 22,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${wallet.balance.toStringAsFixed(2)}',
                            style: AppTypography.amountSmall(
                              color: wallet.isDark ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transactions',
                    style: AppTypography.titleMedium(),
                  ),
                  TextButton(
                    onPressed: () {
                      financeProvider.setTabIndex(1);
                    },
                    child: Text(
                      'View All',
                      style: AppTypography.labelSmall(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Transactions Feed List
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.outline),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: financeProvider.transactions.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: AppColors.outline),
                  itemBuilder: (context, index) {
                    final tx = financeProvider.transactions[index];
                    final isExpense = tx.type == TransactionType.expense;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tx.icon,
                          color: AppColors.onSurface,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        tx.title,
                        style: AppTypography.bodyMedium().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy').format(tx.date),
                        style: AppTypography.labelSmall(color: AppColors.secondary),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isExpense ? '-' : '+'}₹${tx.amount.toStringAsFixed(2)}',
                            style: AppTypography.amountSmall(
                              color: isExpense ? AppColors.onSurface : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isExpense
                                  ? AppColors.onSurface.withValues(alpha: 0.05)
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tx.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isExpense
                                    ? AppColors.onSurface
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

}
