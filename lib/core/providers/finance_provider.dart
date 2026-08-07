import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/budget.dart';
import '../services/supabase_service.dart';
import '../services/preferences_service.dart';
import '../services/sms_service.dart';
import '../theme/app_colors.dart';


class FinanceProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  bool get isDarkTheme => PreferencesService.isDarkTheme;

  void initTheme() {
    AppColors.applyTheme(isDarkTheme);
  }

  Future<void> toggleTheme(bool isDark) async {
    await PreferencesService.setDarkTheme(isDark);
    AppColors.applyTheme(isDark);
    notifyListeners();
  }

  double _netBalance = 0.0;
  double get netBalance => _netBalance;
  
  DateTime? get _earliestBalanceSetAt {
    if (_wallets.isEmpty) return null;
    final dates = _wallets.map((w) => w.balanceSetAt).whereType<DateTime>().toList();
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.first;
  }

  List<TransactionModel> get validTransactions {
    final threshold = _earliestBalanceSetAt;
    if (threshold == null) return _transactions;
    return _transactions.where((tx) => tx.date.isAfter(threshold) || tx.date.isAtSameMomentAs(threshold)).toList();
  }

  // Real Income and Expense totals calculated directly from actual user transactions
  // Only counts transactions that occurred AFTER the initial balance was set.
  double get totalIncome {
    return validTransactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return validTransactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  List<WalletModel> _wallets = [];
  List<WalletModel> get wallets => _wallets;

  // Real & Dynamic Transactions list
  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  // Budgets
  List<BudgetModel> _budgets = [];
  List<BudgetModel> get budgets => _budgets;

  Future<void> loadRealTransactions({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        await SmsService.initialize();
        await SmsService.syncBackgroundQueue();
        await SmsService.scanInboxForTransactions(); 
        
        // Fetch real wallets and overall balance from Supabase
        final fetchedWallets = await SupabaseService.getWallets();
        if (fetchedWallets.isNotEmpty) {
          _wallets = fetchedWallets;
        }
        _budgets = await SupabaseService.getBudgets();
        _netBalance = await SupabaseService.getNetBalance();
      }

      final limit = 50;
      final offset = loadMore ? _transactions.length : 0;
      final rawList = await SupabaseService.getTransactions(limit: limit, offset: offset);
      
      final newTxs = rawList.map((map) {
        final isExpense = map['type'] == 'expense' || map['type'] == TransactionType.expense.name;
        return TransactionModel(
          id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: map['note']?.toString() ?? 'Transaction',
          amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
          date: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
          category: map['category']?.toString() ?? 'General',
          icon: isExpense ? Icons.shopping_bag : Icons.work,
          type: isExpense ? TransactionType.expense : TransactionType.income,
          walletName: 'Main', 
          status: map['status']?.toString() ?? 'Paid',
        );
      }).toList();

      if (loadMore) {
        _transactions.addAll(newTxs);
      } else {
        _transactions = newTxs;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions from Supabase: $e');
    }
  }




  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    
    // Auto-update matching wallet balance
    final walletIndex = _wallets.indexWhere(
      (w) => w.name.toLowerCase() == transaction.walletName.toLowerCase(),
    );
    if (walletIndex != -1) {
      final w = _wallets[walletIndex];
      final newBalance = transaction.type == TransactionType.expense
          ? w.openingBalance - transaction.amount
          : w.openingBalance + transaction.amount;
      _wallets[walletIndex] = WalletModel(
        id: w.id,
        name: w.name,
        openingBalance: newBalance < 0 ? 0 : newBalance,
        icon: w.icon,
        isDark: w.isDark,
      );
    }
    notifyListeners();

    // Persist real transaction to Supabase backend asynchronously
    SupabaseService.createTransaction(transaction);
  }

  Future<void> setBudget(String category, double amount) async {
    final newBudget = BudgetModel(id: '', category: category, limitAmount: amount);
    
    final index = _budgets.indexWhere((b) => b.category == category);
    if (index >= 0) {
      _budgets[index] = newBudget;
    } else {
      _budgets.add(newBudget);
    }
    notifyListeners();
    
    await SupabaseService.upsertBudget(newBudget);
  }

  // Wallet mutators
  Future<void> createWallet(WalletModel wallet) async {
    final newWallet = await SupabaseService.createWallet(wallet);
    if (newWallet != null) {
      _wallets.add(newWallet);
      notifyListeners();
      _netBalance = await SupabaseService.getNetBalance();
      notifyListeners();
    }
  }

  Future<void> updateWallet(WalletModel wallet) async {
    final index = _wallets.indexWhere((w) => w.id == wallet.id);
    if (index >= 0) {
      _wallets[index] = wallet;
      notifyListeners();
      await SupabaseService.updateWallet(wallet);
      _netBalance = await SupabaseService.getNetBalance();
      notifyListeners();
    }
  }

  Future<void> deleteWallet(String id) async {
    _wallets.removeWhere((w) => w.id == id);
    notifyListeners();
    await SupabaseService.deleteWallet(id);
    _netBalance = await SupabaseService.getNetBalance();
    notifyListeners();
  }

}

