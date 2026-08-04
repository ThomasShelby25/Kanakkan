import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/providers/finance_provider.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SettingsScreen({super.key, required this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _darkMode = PreferencesService.isDarkTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: AppTypography.headlineMedium(),
              ),
              const SizedBox(height: 16),

              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.surface,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SupabaseService.userName,
                          style: AppTypography.titleMedium(),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          SupabaseService.userEmail,
                          style: AppTypography.labelSmall(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Preferences Section
              Text(
                'PREFERENCES',
                style: AppTypography.labelCaps(color: AppColors.secondary),
              ),
              const SizedBox(height: 8),
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Dark Theme', style: AppTypography.bodyMedium()),
                      subtitle: Text('Enable dark mode UI',
                          style: AppTypography.labelSmall(color: AppColors.secondary)),
                      secondary: Icon(Icons.dark_mode_outlined, color: AppColors.onSurface),
                      value: _darkMode,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _darkMode = val);
                        Provider.of<FinanceProvider>(context, listen: false).toggleTheme(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Wallet Configuration
              Text(
                'WALLET CONFIGURATION',
                style: AppTypography.labelCaps(color: AppColors.secondary),
              ),
              const SizedBox(height: 8),
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Initial Balances', style: AppTypography.bodyMedium()),
                      subtitle: Text('Set starting balance for your wallets',
                          style: AppTypography.labelSmall(color: AppColors.secondary)),
                      leading: Icon(Icons.account_balance_wallet, color: AppColors.onSurface),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => _showInitialBalanceDialog(context),
                    ),
                  ],
                ),
              ),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: Text(
                    'Log Out',
                    style: AppTypography.titleMedium(color: AppColors.error),
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

  void _showInitialBalanceDialog(BuildContext context) {
    final mainCtrl = TextEditingController(text: PreferencesService.initialMainBalance.toStringAsFixed(2));
    final savingsCtrl = TextEditingController(text: PreferencesService.initialSavingsBalance.toStringAsFixed(2));
    final cashCtrl = TextEditingController(text: PreferencesService.initialCashBalance.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Initial Balances', style: AppTypography.titleMedium()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mainCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Main/Checking Balance (₹)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: savingsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Savings Balance (₹)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cashCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cash Balance (₹)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<FinanceProvider>(context, listen: false);
                await provider.updateInitialBalance('Main', double.tryParse(mainCtrl.text) ?? 0.0);
                await provider.updateInitialBalance('Savings', double.tryParse(savingsCtrl.text) ?? 0.0);
                await provider.updateInitialBalance('Cash', double.tryParse(cashCtrl.text) ?? 0.0);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
