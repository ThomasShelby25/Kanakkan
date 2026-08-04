import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/transaction.dart';
import '../../../core/services/supabase_service.dart';


class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;
  String _amount = "0.00";
  String _selectedPayment = "MAIN";
  String _selectedCategory = "Transport";

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'label': 'FOOD'},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'label': 'SHOP'},
    {'name': 'Transport', 'icon': Icons.directions_car, 'label': 'TRANS'},
    {'name': 'Entertainment', 'icon': Icons.theater_comedy, 'label': 'ENT.'},
  ];

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

    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$_selectedCategory Payment',
      amount: parsedAmount,
      date: DateTime.now(),
      category: _selectedCategory,
      icon: _categories.firstWhere(
          (c) => c['name'] == _selectedCategory,
          orElse: () => _categories[0])['icon'] as IconData,
      type: _selectedType,
      walletName: _selectedPayment,
      status: _selectedType == TransactionType.expense ? 'Paid' : 'Recv',
    );

    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    financeProvider.addTransaction(newTx);
    await SupabaseService.createTransaction(newTx);

    if (mounted) {
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Transaction',
          style: AppTypography.titleMedium(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
              const SizedBox(height: 12),
              // EXPENSE / INCOME Segmented Toggle
              Container(
                width: 240,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.expense;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.expense
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'EXPENSE',
                            style: AppTypography.labelSmall(
                              color: _selectedType == TransactionType.expense
                                  ? AppColors.surface
                                  : AppColors.secondary,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.income;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedType == TransactionType.income
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'INCOME',
                            style: AppTypography.labelSmall(
                              color: _selectedType == TransactionType.income
                                  ? AppColors.surface
                                  : AppColors.secondary,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Large Amount Display
              Text(
                'AMOUNT',
                style: AppTypography.labelCaps(color: AppColors.secondary),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₹',
                    style: AppTypography.amountMedium(color: AppColors.primary),
                  ),

                  const SizedBox(width: 4),
                  Text(
                    _amount,
                    style: AppTypography.amountLarge(fontSize: 40),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Payment Method Selector
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PAYMENT METHOD',
                  style: AppTypography.labelCaps(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['MAIN', 'SAVINGS', 'CASH'].map((method) {
                  final isSelected = _selectedPayment == method;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPayment = method;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? null
                              : Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              method == 'MAIN'
                                  ? Icons.account_balance_wallet
                                  : method == 'SAVINGS'
                                      ? Icons.credit_card
                                      : Icons.payments,
                              color: isSelected ? Colors.white : AppColors.secondary,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              method,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Category Grid
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CATEGORY',
                  style: AppTypography.labelCaps(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['name'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat['name'] as String;
                        });
                      },
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
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cat['icon'] as IconData,
                                color: isSelected ? Colors.white : AppColors.secondary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat['label'] as String,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _saveTransaction,
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  label: Text(
                    'SAVE TRANSACTION',
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
        child: Text(
          label,
          style: AppTypography.amountMedium(fontSize: 18),
        ),
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
