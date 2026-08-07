import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/preferences_service.dart';
import '../../../main.dart';
import '../../../core/services/supabase_service.dart';
import 'login_screen.dart';

class IntroWalkthroughScreen extends StatefulWidget {
  const IntroWalkthroughScreen({super.key});

  @override
  State<IntroWalkthroughScreen> createState() => _IntroWalkthroughScreenState();
}

class _IntroWalkthroughScreenState extends State<IntroWalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.account_balance_wallet_outlined,
      'title': 'Track every penny\nlike a ledger.',
      'subtitle': 'A tactile, robust interface for logging your income and expenses with absolute precision.',
    },
    {
      'icon': Icons.pie_chart_outline,
      'title': 'Set Budgets,\nNot Limits.',
      'subtitle': 'Visualize your cash flow with semantic analytics and strict category guardrails.',
    },
    {
      'icon': Icons.lock_outline,
      'title': 'Your Data,\nLocked in a Vault.',
      'subtitle': 'Enterprise-grade encryption and secure cloud sync powered by Supabase.',
    },
  ];

  void _finishWalkthrough() async {
    await PreferencesService.setHasSeenWalkthrough();
    if (!mounted) return;
    
    // Route to Login Screen with the standard success handler
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: LoginScreen(
            onLoginSuccess: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthWrapper(
                    onLogout: () async {
                      await SupabaseService.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen(onLoginSuccess: _placeholder)),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static void _placeholder() {}

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onSurface, // Vault Black
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(slide['icon'], size: 80, color: AppColors.primary),
                    const SizedBox(height: 48),
                    Text(
                      slide['title'],
                      style: AppTypography.displayLarge(color: Colors.white).copyWith(
                        fontSize: 36,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      slide['subtitle'],
                      style: AppTypography.bodyMedium(color: AppColors.secondary).copyWith(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Navigation Controls
          Positioned(
            bottom: 48,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Dots
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.primary : AppColors.outline,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                // Next / Get Started Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finishWalkthrough();
                    }
                  },
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                    style: AppTypography.titleMedium(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
