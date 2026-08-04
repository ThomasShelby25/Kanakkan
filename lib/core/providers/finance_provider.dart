import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/salary_entry.dart';
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

  // Net Balance and Wallets
  // Net Balance: initial balance + only transactions AFTER the user set their balance
  double get netBalance {
    final initial = PreferencesService.initialCashBalance +
        PreferencesService.initialMainBalance +
        PreferencesService.initialSavingsBalance;
    final trackingStart = PreferencesService.balanceSetAt;
    if (trackingStart == null) return initial; // No tracking date set yet

    final trackedTxs = _transactions.where((tx) => tx.date.isAfter(trackingStart));
    final income = trackedTxs
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final expense = trackedTxs
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    return initial + income - expense;
  }
  
  // Real Income and Expense totals calculated directly from actual user transactions
  double get totalIncome {
    return _transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  final List<WalletModel> _wallets = [
    WalletModel(
      id: 'w1',
      name: 'Cash',
      balance: 0.00,
      icon: Icons.payments,
    ),
    WalletModel(
      id: 'w2',
      name: 'Main',
      balance: 0.00,
      icon: Icons.account_balance,
      isDark: true,
    ),
    WalletModel(
      id: 'w3',
      name: 'Savings',
      balance: 0.00,
      icon: Icons.savings,
    ),
  ];
  List<WalletModel> get wallets => _wallets;

  // Real & Dynamic Transactions list
  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  Future<void> loadRealTransactions() async {
    try {
      await SmsService.initialize();
      await SmsService.syncBackgroundQueue();
      await SmsService.scanInboxForTransactions(); // Scan inbox for missed bank SMS

      final rawList = await SupabaseService.getTransactions();
      _transactions = rawList.map((map) {
        final isExpense = map['type'] == 'expense' || map['type'] == TransactionType.expense.name;
        return TransactionModel(
          id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: map['note']?.toString() ?? 'Transaction',
          amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
          date: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
          category: map['category']?.toString() ?? 'General',
          icon: isExpense ? Icons.shopping_bag : Icons.work,
          type: isExpense ? TransactionType.expense : TransactionType.income,
          walletName: 'Main', // No wallet_name in DB yet, requires join with wallets table
          status: map['status']?.toString() ?? 'Paid',
        );
      }).toList();

      // Recalculate wallet balances dynamically from real transaction history + initial balances
      double cashBal = PreferencesService.initialCashBalance;
      double checkingBal = PreferencesService.initialMainBalance;
      double savingsBal = PreferencesService.initialSavingsBalance;

      for (var tx in _transactions) {
        final change = tx.type == TransactionType.income ? tx.amount : -tx.amount;
        final wName = tx.walletName.toLowerCase();
        if (wName.contains('cash')) {
          cashBal += change;
        } else if (wName.contains('savings')) {
          savingsBal += change;
        } else {
          checkingBal += change;
        }
      }

      _wallets[0] = WalletModel(id: 'w1', name: 'Cash', balance: cashBal, icon: Icons.payments);
      _wallets[1] = WalletModel(id: 'w2', name: 'Main', balance: checkingBal, icon: Icons.account_balance, isDark: true);
      _wallets[2] = WalletModel(id: 'w3', name: 'Savings', balance: savingsBal, icon: Icons.savings);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading transactions from Supabase: $e');
    }
  }

  Future<void> updateInitialBalance(String walletName, double amount) async {
    final wName = walletName.toLowerCase();
    if (wName.contains('cash')) {
      await PreferencesService.setInitialCashBalance(amount);
    } else if (wName.contains('savings')) {
      await PreferencesService.setInitialSavingsBalance(amount);
    } else {
      await PreferencesService.setInitialMainBalance(amount);
    }
    // Record timestamp so only future transactions affect balance
    await PreferencesService.recordBalanceSetNow();
    // Reload to recalculate everything
    await loadRealTransactions();
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
          ? w.balance - transaction.amount
          : w.balance + transaction.amount;
      _wallets[walletIndex] = WalletModel(
        id: w.id,
        name: w.name,
        balance: newBalance < 0 ? 0 : newBalance,
        icon: w.icon,
        isDark: w.isDark,
      );
    }
    notifyListeners();

    // Persist real transaction to Supabase backend asynchronously
    SupabaseService.createTransaction(transaction);
  }


  // Salary record in Rupees
  final SalaryEntryModel _currentSalary = SalaryEntryModel(
    id: 's1',
    period: 'OCT 2023',
    grossSalary: 75000.00,
    incomeTax: 10000.00,
    retirement401k: 2500.00,
    netCredited: 62500.00,
    nextPayDate: DateTime.now().add(const Duration(days: 14)),
  );
  SalaryEntryModel get currentSalary => _currentSalary;
}

