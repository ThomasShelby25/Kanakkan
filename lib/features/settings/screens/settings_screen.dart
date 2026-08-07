import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/providers/finance_provider.dart';
import '../../budgets/screens/budget_screen.dart';
import '../../budgets/screens/wallet_manager_screen.dart';
import 'edit_profile_screen.dart';

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
    final avatarUrl = SupabaseService.currentUser?.userMetadata?['avatar_url'];
    final displayName = SupabaseService.currentUser?.userMetadata?['display_name']
        ?? SupabaseService.currentUser?.email?.split('@')[0]
        ?? 'User';
    final email = SupabaseService.currentUser?.email ?? '';
    final phone = SupabaseService.currentUser?.userMetadata?['phone_number']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PROFILE BLOCK ────────────────────────────────────────────
              // Not a card. Just a raw header block with generous vertical space.
              InkWell(
                onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                  if (updated == true) setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          shape: BoxShape.circle,
                          image: avatarUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(avatarUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: avatarUrl == null
                            ? Icon(Icons.person_rounded, color: AppColors.secondary, size: 28)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: AppTypography.headlineSmall()),
                            if (email.isNotEmpty)
                              Text(email, style: AppTypography.labelSmall(color: AppColors.secondary)),
                            if (phone.isNotEmpty)
                              Text(phone, style: AppTypography.labelSmall(color: AppColors.secondary)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.secondary, size: 20),
                    ],
                  ),
                ),
              ),

              // Structural separator — means something: end of identity block
              Divider(height: 1, color: AppColors.outline, indent: 20, endIndent: 20),

              // ── PREFERENCES GROUP ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Preferences', style: AppTypography.labelCaps(color: AppColors.secondary)),
              ),
              _buildSettingRow(
                label: 'Dark Theme',
                meta: 'Switch to dark ledger view',
                trailing: Switch(
                  value: _darkMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _darkMode = val);
                    Provider.of<FinanceProvider>(context, listen: false).toggleTheme(val);
                  },
                ),
              ),

              const SizedBox(height: 8),
              Divider(height: 1, color: AppColors.outline, indent: 20, endIndent: 20),

              // ── DATA GROUP ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Data', style: AppTypography.labelCaps(color: AppColors.secondary)),
              ),
              _buildSettingRow(
                label: 'Budgets & Limits',
                meta: 'Monthly spend limits by category',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
              ),
              _buildSettingRow(
                label: 'Accounts',
                meta: 'Add, rename, or remove wallets',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletManagerScreen())),
              ),

              const SizedBox(height: 32),
              Divider(height: 1, color: AppColors.outline, indent: 20, endIndent: 20),

              // ── SIGN OUT ─────────────────────────────────────────────────
              // Not a button — just a tappable row. Low visual weight intentionally.
              InkWell(
                onTap: widget.onLogout,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      Text(
                        'Sign out',
                        style: AppTypography.bodyMedium(color: AppColors.error)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
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

  // A flat ledger-style row with no icon circle
  Widget _buildSettingRow({
    required String label,
    required String meta,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(meta, style: AppTypography.labelSmall(color: AppColors.secondary)),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right, color: AppColors.secondary, size: 18),
          ],
        ),
      ),
    );
  }
}
