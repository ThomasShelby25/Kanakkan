import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/models/transaction.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedIndex = -1;

  Map<String, double> _calculateCategoryTotals(List<TransactionModel> txs) {
    Map<String, double> totals = {};
    for (var tx in txs) {
      if (tx.type == TransactionType.expense) {
        totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
      }
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final categoryTotals = _calculateCategoryTotals(provider.validTransactions);
    
    // Sort categories by amount
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalExpense = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    // Category-semantic colors — each tied to the real-world meaning of the category
    // NOT sequential rainbow cycling
    const Map<String, Color> categoryColors = {
      'Food':          Color(0xFFD97706), // Amber warmth — heat, kitchen, organic
      'Shopping':      Color(0xFFB45309), // Dusty sienna — commerce, leather, retail
      'Transport':     Color(0xFF2563EB), // Cool slate blue — roads, movement, sky
      'Entertainment': Color(0xFF7C3AED), // Muted violet — screens, leisure, night
      'General':       Color(0xFF4B5563), // Charcoal gray — neutral catch-all
      'Transfer':      Color(0xFF059669), // Teal green — movement between accounts
    };
    // Fallback palette for categories not in the map
    const List<Color> fallbackColors = [
      Color(0xFF9D4E15),
      Color(0xFF1D4ED8),
      Color(0xFF6D28D9),
      Color(0xFF065F46),
    ];

    Color colorForCategory(String name, int index) {
      return categoryColors[name] ?? fallbackColors[index % fallbackColors.length];
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: AppTypography.headlineMedium(),
              ),
              const SizedBox(height: 4),
              Text(
                'Spending Breakdown',
                style: AppTypography.bodyMedium(color: AppColors.secondary),
              ),
              const SizedBox(height: 32),
              
              if (totalExpense == 0)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text('No expenses recorded.', style: AppTypography.bodyMedium(color: AppColors.secondary)),
                  ),
                )
              else ...[
                // Donut Chart
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: List.generate(sortedCategories.length, (i) {
                        final isTouched = i == _touchedIndex;
                        final fontSize = isTouched ? 14.0 : 0.0;
                        final radius = isTouched ? 58.0 : 50.0;
                        final entry = sortedCategories[i];
                        final percentage = (entry.value / totalExpense) * 100;
                        final sectionColor = colorForCategory(entry.key, i);

                        return PieChartSectionData(
                          color: sectionColor,
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                Text(
                  'TOP CATEGORIES',
                  style: AppTypography.labelCaps(color: AppColors.secondary),
                ),
                const SizedBox(height: 12),
                
                // Legend and Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: List.generate(sortedCategories.length, (i) {
                      final entry = sortedCategories[i];
                      final dotColor = colorForCategory(entry.key, i);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              entry.key,
                              style: AppTypography.bodyMedium(),
                            ),
                            const Spacer(),
                            Text(
                              '₹${entry.value.toStringAsFixed(2)}',
                              style: AppTypography.amountSmall(
                                color: AppColors.onSurface,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 100), // Padding for bottom nav
              ],
            ],
          ),
        ),
      ),
    );
  }
}
