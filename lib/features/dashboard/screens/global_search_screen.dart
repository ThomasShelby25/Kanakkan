import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/wallet.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    
    List<TransactionModel> txResults = [];
    List<WalletModel> walletResults = [];
    
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      txResults = provider.transactions.where((tx) => 
        tx.title.toLowerCase().contains(q) || 
        tx.category.toLowerCase().contains(q)
      ).toList();
      
      walletResults = provider.wallets.where((w) => 
        w.name.toLowerCase().contains(q)
      ).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.onSurface),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search transactions, wallets...',
            border: InputBorder.none,
            hintStyle: AppTypography.bodyMedium(color: AppColors.secondary),
          ),
          style: AppTypography.bodyMedium(),
          onChanged: (val) => setState(() => _query = val),
        ),
      ),
      body: _query.isEmpty
          ? Center(child: Text('Type to search', style: AppTypography.bodyMedium(color: AppColors.secondary)))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (walletResults.isNotEmpty) ...[
                  Text('ACCOUNTS', style: AppTypography.labelCaps()),
                  const SizedBox(height: 12),
                  ...walletResults.map((w) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(w.icon, color: AppColors.secondary),
                      title: Text(w.name, style: AppTypography.titleMedium()),
                      trailing: Text('₹${w.balance.toStringAsFixed(0)}', style: AppTypography.amountSmall(fontSize: 16)),
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
                if (txResults.isNotEmpty) ...[
                  Text('TRANSACTIONS', style: AppTypography.labelCaps()),
                  const SizedBox(height: 12),
                  ...txResults.map((tx) {
                    final isExpense = tx.type == TransactionType.expense;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(tx.title, style: AppTypography.titleMedium()),
                        subtitle: Text(tx.category, style: AppTypography.labelSmall(color: AppColors.secondary)),
                        trailing: Text('${isExpense ? '−' : '+'}₹${tx.amount.toStringAsFixed(2)}', 
                          style: AppTypography.amountSmall(
                            fontSize: 14,
                            color: isExpense ? AppColors.onSurface : AppColors.incomeGreen,
                          )
                        ),
                      ),
                    );
                  }),
                ],
                if (walletResults.isEmpty && txResults.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text('No results found for "$_query"', style: AppTypography.bodyMedium(color: AppColors.secondary))),
                  ),
              ],
            ),
    );
  }
}
