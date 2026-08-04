import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';

import 'pill_bottom_nav.dart';
import '../../features/dashboard/screens/home_dashboard_screen.dart';
import '../../features/transactions/screens/transaction_history_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

class AppShell extends StatelessWidget {
  final VoidCallback onLogout;

  const AppShell({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final currentIndex = financeProvider.currentTabIndex;

    final screens = [
      const HomeDashboardScreen(),
      const TransactionHistoryScreen(),
      SettingsScreen(onLogout: onLogout),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PillBottomNav(
              currentIndex: currentIndex,
              onTap: (index) {
                financeProvider.setTabIndex(index);
              },
              onAddTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}
