import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/transaction.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/report_service.dart';

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

              // Transactions Feed List
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found',
                          style: AppTypography.bodyMedium(color: AppColors.secondary),
                        ),
                      )
                    : Material(
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.outline),
                        ),
                        child: ListView.separated(
                          controller: _scrollController,
                          itemCount: filteredTransactions.length + (_isLoadingMore ? 1 : 0),
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: AppColors.outline),
                          itemBuilder: (context, index) {
                            if (index == filteredTransactions.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final tx = filteredTransactions[index];
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
                                '${DateFormat('MMM dd, yyyy').format(tx.date)} • ${tx.walletName}',
                                style: AppTypography.labelSmall(color: AppColors.secondary),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${isExpense ? '-' : '+'}₹${tx.amount.toStringAsFixed(2)}',
                                    style: AppTypography.amountSmall(
                                      color: isExpense
                                          ? AppColors.onSurface
                                          : AppColors.primary,
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
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
