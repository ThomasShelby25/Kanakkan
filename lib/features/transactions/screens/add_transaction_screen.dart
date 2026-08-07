import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/wallet.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existingTransaction;
  
  const AddTransactionScreen({super.key, this.existingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;
  String _amount = "0.00";
  
  // Normal Expense/Income
  String? _selectedPayment;
  String _selectedCategory = "Transport";

  // Transfer specific
  String? _fromWallet;
  String? _toWallet;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'label': 'FOOD'},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'label': 'SHOP'},
    {'name': 'Transport', 'icon': Icons.directions_car, 'label': 'TRANS'},
    {'name': 'Entertainment', 'icon': Icons.theater_comedy, 'label': 'ENT.'},
  ];

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _selectedType = tx.type;
      _amount = tx.amount.toStringAsFixed(2);
      _selectedCategory = tx.category;
      _selectedPayment = tx.walletName;
      _selectedDate = tx.date;
      if (tx.category == 'Transfer') {
        _selectedType = TransactionType.transfer;
        // Basic fallback for transfer edit, though complex to perfectly reverse
        _fromWallet = tx.walletName;
      }
    }

    // Initialize default wallets after frame if not editing or if fields are empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wallets = Provider.of<FinanceProvider>(context, listen: false).wallets;
      if (wallets.isNotEmpty) {
        setState(() {
          _selectedPayment ??= wallets.first.name;
          _fromWallet ??= wallets.first.name;
          _toWallet ??= wallets.length > 1 ? wallets[1].name : wallets.first.name;
        });
      }
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        // Keep the current time, just change the date
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  void _appendDigit(String digit) {
    setState(() {
      if (_amount == "0.00") {
        _amount = digit == "." ? "0." : digit;
      } else {
        if (digit == "." && _amount.contains(".")) return;
        if (_amount.contains(".") && _amount.split(".")[1].length >= 2) return;
        _amount += digit;
      }
    });
  }

  void _deleteDigit() {
    setState(() {
      if (_amount.length > 1 && _amount != "0.00") {
        _amount = _amount.substring(0, _amount.length - 1);
        if (_amount.isEmpty) _amount = "0.00";
      } else {
        _amount = "0.00";
      }
    });
  }

  void _saveTransaction() async {
    final parsedAmount = double.tryParse(_amount) ?? 0.00;
    if (parsedAmount <= 0) return;

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    final isEditing = widget.existingTransaction != null;

    if (_selectedType == TransactionType.transfer) {
      if (_fromWallet == null || _toWallet == null || _fromWallet == _toWallet) return;
      
      // If editing a transfer, it gets complicated because it's 2 transactions.
      // For now, if it's a transfer, we just create new ones or edit one side.
      // 1. Expense from FromWallet
      final txOut = TransactionModel(
        id: isEditing ? widget.existingTransaction!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Transfer to $_toWallet',
        amount: parsedAmount,
        date: _selectedDate,
        category: 'Transfer',
        icon: Icons.swap_horiz,
        type: TransactionType.expense,
        walletName: _fromWallet!,
        status: 'Paid',
      );
      
      if (!isEditing) {
        // 2. Income to ToWallet
        final txIn = TransactionModel(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          title: 'Transfer from $_fromWallet',
          amount: parsedAmount,
          date: _selectedDate.add(const Duration(seconds: 1)),
          category: 'Transfer',
          icon: Icons.swap_horiz,
          type: TransactionType.income,
          walletName: _toWallet!,
          status: 'Recv',
        );
        financeProvider.addTransaction(txOut);
        financeProvider.addTransaction(txIn);
      } else {
        financeProvider.updateTransaction(txOut);
      }

    } else {
      if (_selectedPayment == null) return;
      // Normal transaction
      final newTx = TransactionModel(
        id: isEditing ? widget.existingTransaction!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: '$_selectedCategory Payment',
        amount: parsedAmount,
        date: _selectedDate,
        category: _selectedCategory,
        icon: _categories.firstWhere((c) => c['name'] == _selectedCategory, orElse: () => _categories[0])['icon'] as IconData,
        type: _selectedType,
        walletName: _selectedPayment!,
        status: _selectedType == TransactionType.expense ? 'Paid' : 'Recv',
      );

      if (isEditing) {
        financeProvider.updateTransaction(newTx);
      } else {
        financeProvider.addTransaction(newTx);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final wallets = Provider.of<FinanceProvider>(context).wallets;
    final isTransfer = _selectedType == TransactionType.transfer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.existingTransaction != null ? 'Edit Transaction' : 'Add Transaction', style: AppTypography.titleMedium()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                
                // 3-Way Segmented Toggle
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton('EXPENSE', TransactionType.expense),
                      _buildTabButton('INCOME', TransactionType.income),
                      _buildTabButton('TRANSFER', TransactionType.transfer),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Large Amount Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('AMOUNT', style: AppTypography.labelCaps(color: AppColors.secondary)),
                    GestureDetector(
                      onTap: () => _pickDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                              style: AppTypography.labelSmall(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('₹', style: AppTypography.amountMedium(color: AppColors.primary)),
                    const SizedBox(width: 4),
                    Text(_amount, style: AppTypography.amountLarge(fontSize: 40)),
                  ],
                ),
                const SizedBox(height: 24),

                // Dynamic Wallet Selectors
                if (isTransfer) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FROM WALLET', style: AppTypography.labelCaps(color: AppColors.secondary)),
                            const SizedBox(height: 8),
                            _buildWalletDropdown(
                              value: _fromWallet,
                              wallets: wallets,
                              onChanged: (v) => setState(() => _fromWallet = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.arrow_forward_rounded, color: AppColors.secondary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TO WALLET', style: AppTypography.labelCaps(color: AppColors.secondary)),
                            const SizedBox(height: 8),
                            _buildWalletDropdown(
                              value: _toWallet,
                              wallets: wallets,
                              onChanged: (v) => setState(() => _toWallet = v),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('PAYMENT WALLET', style: AppTypography.labelCaps(color: AppColors.secondary)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wallets.length,
                      itemBuilder: (context, index) {
                        final w = wallets[index];
                        final isSelected = _selectedPayment == w.name;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPayment = w.name),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(w.icon, color: isSelected ? Colors.white : AppColors.secondary, size: 20),
                                const SizedBox(height: 4),
                                Text(w.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.secondary)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Category Grid (Only for Expense/Income)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('CATEGORY', style: AppTypography.labelCaps(color: AppColors.secondary)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['name'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat['name'] as String),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.outline,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(cat['icon'] as IconData, color: isSelected ? Colors.white : AppColors.secondary, size: 18),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat['label'] as String,
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.secondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Numeric Keypad
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      for (var i = 1; i <= 9; i++) _buildKeypadButton(i.toString()),
                      _buildKeypadButton('.'),
                      _buildKeypadButton('0'),
                      _buildKeypadIconButton(Icons.backspace_outlined, _deleteDigit),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    onPressed: _saveTransaction,
                    icon: Icon(isTransfer ? Icons.swap_horiz : Icons.check_circle_outline, size: 22),
                    label: Text(
                      isTransfer ? 'CONFIRM TRANSFER' : 'SAVE TRANSACTION',
                      style: AppTypography.titleMedium(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, TransactionType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.labelSmall(
              color: isSelected ? AppColors.surface : AppColors.secondary,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletDropdown({required String? value, required List<WalletModel> wallets, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          dropdownColor: AppColors.surface,
          items: wallets.map((w) {
            return DropdownMenuItem<String>(
              value: w.name,
              child: Text(w.name, style: AppTypography.bodyMedium()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String label) {
    return GestureDetector(
      onTap: () => _appendDigit(label),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTypography.amountMedium(fontSize: 18)),
      ),
    );
  }

  Widget _buildKeypadIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: AppColors.onSurface),
      ),
    );
  }
}
