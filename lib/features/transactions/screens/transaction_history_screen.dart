import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/transaction.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/report_service.dart';
import 'add_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = "ALL";
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await context.read<FinanceProvider>().loadRealTransactions(loadMore: true);
    if (mounted) setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);

    final filteredTransactions = financeProvider.validTransactions.where((tx) {
      if (_selectedFilter == "EXPENSE" && tx.type != TransactionType.expense) return false;
      if (_selectedFilter == "INCOME" && tx.type != TransactionType.income) return false;
      if (_searchController.text.isNotEmpty) {
        return tx.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            tx.category.toLowerCase().contains(_searchController.text.toLowerCase());
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaction History',
                    style: AppTypography.headlineMedium(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                      tooltip: 'Export as PDF',
                      onPressed: () async {
                        final provider = Provider.of<FinanceProvider>(context, listen: false);
                        
                        final filteredIncome = filteredTransactions.where((tx) => tx.type == TransactionType.income).fold(0.0, (sum, tx) => sum + tx.amount);
                        final filteredExpense = filteredTransactions.where((tx) => tx.type == TransactionType.expense).fold(0.0, (sum, tx) => sum + tx.amount);
                        
                        await ReportService.generateAndPrintTransactionReport(
                          userName: SupabaseService.currentUser?.email?.split('@')[0] ?? 'User',
                          netBalance: provider.netBalance,
                          totalIncome: filteredIncome,
                          totalExpense: filteredExpense,
                          transactions: filteredTransactions,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: Icon(Icons.search, color: AppColors.secondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Filter Chips Row
              Row(
                children: ['ALL', 'EXPENSE', 'INCOME'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.outline,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Transactions Feed — flat ledger list, no card container
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found',
                          style: AppTypography.bodyMedium(color: AppColors.secondary),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredTransactions.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredTransactions.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final tx = filteredTransactions[index];
                            final isExpense = tx.type == TransactionType.expense;
                            return GestureDetector(
                              onTap: () => _showTransactionOptions(context, tx),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.transparent, // Ensure taps register
                                  border: Border(
                                    bottom: BorderSide(color: AppColors.outline, width: 1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        tx.category.isNotEmpty ? tx.category[0].toUpperCase() : '?',
                                        style: AppTypography.labelCaps(color: AppColors.secondary)
                                            .copyWith(fontSize: 11, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.title,
                                            style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${DateFormat('MMM d, yyyy').format(tx.date)} · ${tx.walletName}',
                                            style: AppTypography.labelSmall(color: AppColors.secondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isExpense ? '−' : '+'}₹${tx.amount.toStringAsFixed(2)}',
                                      style: AppTypography.amountSmall(
                                        color: isExpense ? AppColors.onSurface : AppColors.incomeGreen,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
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

  void _showTransactionOptions(BuildContext context, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tx.category.isNotEmpty ? tx.category[0].toUpperCase() : '?',
                        style: AppTypography.titleMedium(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.title, style: AppTypography.titleMedium()),
                          Text('₹${tx.amount.toStringAsFixed(2)}', style: AppTypography.amountSmall(color: AppColors.secondary, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: AppColors.outline),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: AppColors.onSurface),
                title: Text('Edit Transaction', style: AppTypography.bodyMedium()),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddTransactionScreen(existingTransaction: tx)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                title: Text('Delete Transaction', style: AppTypography.bodyMedium().copyWith(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await context.read<FinanceProvider>().deleteTransaction(tx.id);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
