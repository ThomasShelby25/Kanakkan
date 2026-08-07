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
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.outline),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final updated = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    if (updated == true) {
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            image: SupabaseService.currentUser?.userMetadata?['avatar_url'] != null
                                ? DecorationImage(
                                    image: NetworkImage(SupabaseService.currentUser!.userMetadata!['avatar_url']),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: SupabaseService.currentUser?.userMetadata?['avatar_url'] == null
                              ? Icon(Icons.person_rounded, color: AppColors.primary, size: 28)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                SupabaseService.currentUser?.userMetadata?['display_name'] 
                                    ?? SupabaseService.currentUser?.email?.split('@')[0] 
                                    ?? 'User',
                                style: AppTypography.titleMedium(),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                SupabaseService.currentUser?.email ?? 'Not logged in',
                                style: AppTypography.labelSmall(color: AppColors.secondary),
                              ),
                              if (SupabaseService.currentUser?.userMetadata?['phone_number'] != null && 
                                  SupabaseService.currentUser?.userMetadata?['phone_number'].toString().isNotEmpty == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    SupabaseService.currentUser!.userMetadata!['phone_number'],
                                    style: AppTypography.labelSmall(color: AppColors.secondary),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'EDIT',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
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

              // Features
              Text(
                'FEATURES',
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
                      title: Text('Budgets & Goals', style: AppTypography.bodyMedium()),
                      subtitle: Text('Set limits for category spending',
                          style: AppTypography.labelSmall(color: AppColors.secondary)),
                      leading: Icon(Icons.track_changes, color: AppColors.onSurface),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen()));
                      },
                    ),
                    Divider(color: AppColors.outline, height: 1),
                    ListTile(
                      title: Text('Manage Wallets', style: AppTypography.bodyMedium()),
                      subtitle: Text('Add, edit, or delete accounts',
                          style: AppTypography.labelSmall(color: AppColors.secondary)),
                      leading: Icon(Icons.account_balance_wallet, color: AppColors.onSurface),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletManagerScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
}
