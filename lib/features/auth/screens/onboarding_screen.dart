import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/app_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _mainController = TextEditingController();
  final _cashController = TextEditingController();
  final _savingsController = TextEditingController();
  bool _isLoading = false;
  int _focusedIndex = -1;

  Future<void> _submit() async {
    final mainBal = double.tryParse(_mainController.text) ?? 0.0;
    final cashBal = double.tryParse(_cashController.text) ?? 0.0;
    final savingsBal = double.tryParse(_savingsController.text) ?? 0.0;

    setState(() => _isLoading = true);
    await SupabaseService.setupInitialWallets(cashBal, mainBal, savingsBal);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppShell(onLogout: () {})),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _cashController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top block: Identity / Context ────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand mark — consistent with Login screen
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Set your\nstarting balances.',
                      style: AppTypography.displayLarge(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter what you currently hold in each account.\nYou can always edit these later.',
                      style: AppTypography.bodyMedium(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Structural divider: end of context, start of data ─────────
              Divider(height: 1, color: AppColors.outline),

              // ── Wallet input rows (ledger-style, not form-field cards) ────
              _buildWalletRow(
                index: 0,
                label: 'Main Bank',
                meta: 'Primary bank account',
                icon: Icons.account_balance_outlined,
                controller: _mainController,
              ),
              Divider(height: 1, color: AppColors.outline, indent: 20, endIndent: 20),
              _buildWalletRow(
                index: 1,
                label: 'Cash',
                meta: 'Physical cash in hand',
                icon: Icons.payments_outlined,
                controller: _cashController,
              ),
              Divider(height: 1, color: AppColors.outline, indent: 20, endIndent: 20),
              _buildWalletRow(
                index: 2,
                label: 'Savings',
                meta: 'Savings or secondary account',
                icon: Icons.savings_outlined,
                controller: _savingsController,
              ),
              Divider(height: 1, color: AppColors.outline),

              const SizedBox(height: 40),

              // ── CTA ───────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Create my accounts',
                                style: AppTypography.titleMedium(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'You can skip and set balances to ₹0 for now',
                        style: AppTypography.labelSmall(color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // A flat ledger row with inline balance input — no card, no form chrome
  Widget _buildWalletRow({
    required int index,
    required String label,
    required String meta,
    required IconData icon,
    required TextEditingController controller,
  }) {
    final isFocused = _focusedIndex == index;

    return Focus(
      onFocusChange: (focused) {
        setState(() => _focusedIndex = focused ? index : -1);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Small icon — communicates account type, not decoration
            Icon(
              icon,
              size: 20,
              color: isFocused ? AppColors.primary : AppColors.secondary,
            ),
            const SizedBox(width: 16),
            // Label + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium()
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    meta,
                    style: AppTypography.labelSmall(color: AppColors.secondary),
                  ),
                ],
              ),
            ),
            // Inline balance input — right-aligned, minimal chrome
            SizedBox(
              width: 120,
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                style: AppTypography.amountSmall(color: AppColors.onSurface),
                onTap: () => setState(() => _focusedIndex = index),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: AppTypography.amountSmall(color: AppColors.secondary),
                  prefixText: '₹ ',
                  prefixStyle:
                      AppTypography.labelSmall(color: AppColors.secondary),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
