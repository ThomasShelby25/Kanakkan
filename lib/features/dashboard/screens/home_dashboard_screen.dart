import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/transaction.dart';
import '../../budgets/screens/wallet_manager_screen.dart';
import 'notifications_screen.dart';
import 'global_search_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  // ── Signature Animation: Balance counter rolling up ──────────────────────
  late AnimationController _balanceController;
  late Animation<double> _balanceAnimation;
  double _prevBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _balanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _balanceAnimation = CurvedAnimation(
      parent: _balanceController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinanceProvider>(
        context,
        listen: false,
      ).loadRealTransactions().then((_) {
        if (mounted) _balanceController.forward();
      });
    });
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  void _animateToNewBalance(double newBalance) {
    if (newBalance != _prevBalance) {
      _balanceAnimation = Tween<double>(begin: _prevBalance, end: newBalance)
          .animate(
            CurvedAnimation(
              parent: _balanceController,
              curve: Curves.easeOutCubic,
            ),
          );
      _prevBalance = newBalance;
      _balanceController
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    _animateToNewBalance(provider.netBalance);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── TOP NAV BAR ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'KANAKKAN',
                      style: AppTypography.displayLarge(color: AppColors.onSurface).copyWith(fontSize: 20, letterSpacing: 2),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.search, color: AppColors.onSurface),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalSearchScreen())),
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications_none, color: AppColors.onSurface),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── HERO SECTION: Large breathing room ──────────────────────
              _buildHeroCard(provider),

              // ── WALLETS: Swipeable PageView, not a flat row ──────────────
              _buildWalletsSection(context, provider),

              // ── STAT ROW: Tight, data-dense, no red decoration ───────────
              _buildStatRow(provider),

              // ── TRANSACTIONS: Ledger-style list ─────────────────────────
              _buildTransactionSection(provider),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO CARD — The ONE bold, signature moment of the screen.
  // Deep shadow, 24px radius, large vertical breathing room.
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeroCard(FinanceProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: AppColors.onSurface, // Dark card — only one on screen
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.25),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NET BALANCE',
            style: AppTypography.labelCaps(color: Colors.white38),
          ),
          const SizedBox(height: 12),
          // Signature moment: animated rolling counter
          AnimatedBuilder(
            animation: _balanceAnimation,
            builder: (context, _) {
              final displayValue =
                  _balanceAnimation.value * provider.netBalance;
              return Text(
                '₹${displayValue.toStringAsFixed(2)}',
                style: AppTypography.amountLarge(
                  color: Colors.white,
                  fontSize: 40,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Across ${provider.wallets.length} accounts',
                  style: AppTypography.labelSmall(color: Colors.white60),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM yyyy').format(DateTime.now()),
                style: AppTypography.labelSmall(color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WALLETS SECTION — Horizontal scrolling, not a cramped flat row.
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWalletsSection(BuildContext context, FinanceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Accounts', style: AppTypography.titleMedium()),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WalletManagerScreen(),
                  ),
                ),
                child: Text(
                  'Manage',
                  style: AppTypography.labelSmall(
                    color: AppColors.primary,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        if (provider.wallets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'No accounts yet.',
              style: AppTypography.bodyMedium(color: AppColors.secondary),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.wallets.length,
              itemBuilder: (context, index) {
                final wallet = provider.wallets[index];
                return Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // Flat cards with just border — no shadow, no competition with hero
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(wallet.icon, color: AppColors.secondary, size: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${wallet.balance.toStringAsFixed(0)}',
                            style: AppTypography.amountSmall(
                              color: AppColors.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            wallet.name,
                            style: AppTypography.labelSmall(
                              color: AppColors.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STAT ROW — Tight data-dense strip. No decorative red. Just numbers.
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStatRow(FinanceProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCell(
              label: 'IN',
              value: '+₹${provider.totalIncome.toStringAsFixed(0)}',
              valueColor: AppColors.incomeGreen,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.outline),
          Expanded(
            child: _buildStatCell(
              label: 'OUT',
              value: '-₹${provider.totalExpense.toStringAsFixed(0)}',
              valueColor: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelCaps()),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.amountSmall(color: valueColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TRANSACTIONS — Ledger-style. No icon circles. Grouped by date with
  // date headers instead of inline dividers.
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTransactionSection(FinanceProvider provider) {
    final txs = provider.transactions.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent', style: AppTypography.titleMedium()),
              TextButton(
                onPressed: () {
                  provider.setTabIndex(2);
                },
                child: Text(
                  'View all',
                  style: AppTypography.labelSmall(
                    color: AppColors.primary,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (txs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Text(
              'No transactions yet.',
              style: AppTypography.bodyMedium(color: AppColors.secondary),
            ),
          )
        else
          // Flat ledger list — no card container wrapping the whole list
          Column(children: txs.map((tx) => _buildLedgerRow(tx)).toList()),
      ],
    );
  }

  Widget _buildLedgerRow(TransactionModel tx) {
    final isExpense = tx.type == TransactionType.expense;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
      ),
      child: Row(
        children: [
          // Category initial chip — carries real info (what type of spend)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              tx.category.isNotEmpty ? tx.category[0].toUpperCase() : '?',
              style: AppTypography.labelCaps(
                color: AppColors.secondary,
              ).copyWith(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: AppTypography.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM d').format(tx.date),
                  style: AppTypography.labelSmall(color: AppColors.secondary),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '−' : '+'}₹${tx.amount.toStringAsFixed(2)}',
            style: AppTypography.amountSmall(
              color: isExpense ? AppColors.onSurface : AppColors.incomeGreen,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
