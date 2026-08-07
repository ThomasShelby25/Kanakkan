import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/wallet.dart';

class WalletManagerScreen extends StatefulWidget {
  const WalletManagerScreen({super.key});

  @override
  State<WalletManagerScreen> createState() => _WalletManagerScreenState();
}

class _WalletManagerScreenState extends State<WalletManagerScreen> {
  void _showWalletDialog(BuildContext context, {WalletModel? existingWallet}) {
    final isEditing = existingWallet != null;
    final nameCtrl = TextEditingController(text: isEditing ? existingWallet.name : '');
    final balanceCtrl = TextEditingController(text: isEditing ? existingWallet.openingBalance.toStringAsFixed(2) : '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(isEditing ? 'Edit Wallet' : 'New Wallet', style: AppTypography.titleMedium()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: AppTypography.bodyMedium(),
                decoration: InputDecoration(
                  labelText: 'Wallet Name (e.g. HDFC Bank)',
                  labelStyle: TextStyle(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceCtrl,
                keyboardType: TextInputType.number,
                style: AppTypography.bodyMedium(),
                decoration: InputDecoration(
                  labelText: 'Opening Balance (₹)',
                  labelStyle: TextStyle(color: AppColors.secondary),
                ),
              ),
            ],
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
                final name = nameCtrl.text.trim();
                final balance = double.tryParse(balanceCtrl.text) ?? 0.0;
                if (name.isEmpty) return;

                final provider = Provider.of<FinanceProvider>(context, listen: false);
                
                if (isEditing) {
                  final updated = WalletModel(
                    id: existingWallet.id,
                    name: name,
                    openingBalance: balance,
                    balanceSetAt: existingWallet.balanceSetAt ?? DateTime.now(),
                    icon: existingWallet.icon,
                    isDark: existingWallet.isDark,
                  );
                  await provider.updateWallet(updated);
                } else {
                  final newWallet = WalletModel(
                    id: '', // DB will generate
                    name: name,
                    openingBalance: balance,
                    balanceSetAt: DateTime.now(),
                    icon: Icons.account_balance_wallet,
                    isDark: false,
                  );
                  await provider.createWallet(newWallet);
                }
                
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WalletModel wallet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Wallet?', style: AppTypography.titleMedium(color: AppColors.error)),
        content: Text(
          'Are you sure you want to delete "${wallet.name}"? This action cannot be undone.',
          style: AppTypography.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.secondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () async {
              final provider = Provider.of<FinanceProvider>(context, listen: false);
              await provider.deleteWallet(wallet.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final wallets = provider.wallets;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Wallets', style: AppTypography.titleMedium()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showWalletDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final w = wallets[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: w.isDark ? const Color(0xFF1A1C1C) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline),
            ),
            child: ListTile(
              leading: Icon(w.icon, color: w.isDark ? Colors.white : AppColors.onSurface),
              title: Text(w.name, style: AppTypography.titleMedium(color: w.isDark ? Colors.white : AppColors.onSurface)),
              subtitle: Text(
                'Opening: ₹${w.openingBalance.toStringAsFixed(2)}',
                style: AppTypography.labelSmall(color: w.isDark ? Colors.white70 : AppColors.secondary),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_rounded, color: w.isDark ? Colors.white70 : AppColors.secondary, size: 20),
                    onPressed: () => _showWalletDialog(context, existingWallet: w),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    onPressed: () => _confirmDelete(context, w),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
