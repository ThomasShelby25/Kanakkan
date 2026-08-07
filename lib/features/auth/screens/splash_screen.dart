import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../main.dart'; // To access AuthWrapper
import 'login_screen.dart';
import 'intro_walkthrough_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _currentGlyph = '0';
  bool _isTickerDone = false;
  bool _showWord = false;
  bool _showLine = false;
  
  final List<String> _glyphs = ['0', '3', '7', 'K'];
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    int ticks = 0;
    // Slowed down from 55ms to 80ms per tick for a more readable roll
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) return;
      setState(() {
        _currentGlyph = _glyphs[ticks % _glyphs.length];
        ticks++;
        
        // Let it tick slightly longer (12 ticks instead of 10)
        if (ticks > 12) {
          _tickerTimer?.cancel();
          _currentGlyph = 'K';
          _isTickerDone = true;
          _showWord = true;
          
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => _showLine = true);
            
            // Hold the final resolved frame for 1.8 seconds (up from 1.2) before routing
            Future.delayed(const Duration(milliseconds: 1800), () {
              if (mounted) _routeToNextScreen();
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  Future<void> _routeToNextScreen() async {
    final currentUser = SupabaseService.client.auth.currentSession;
    
    if (currentUser != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800), // Slightly slower crossfade
          pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: AuthWrapper(
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
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: PreferencesService.hasSeenWalkthrough
                ? LoginScreen(
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
                  )
                : const IntroWalkthroughScreen(),
          ),
        ),
      );
    }
  }

  static void _placeholder() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onSurface, // Dark charcoal vault black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The Ticker Glyph
            Text(
              _currentGlyph,
              style: AppTypography.displayLarge(
                color: _isTickerDone ? Colors.white : AppColors.primary,
              ).copyWith(
                fontSize: 64,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            
            // The Word Reveal
            AnimatedSlide(
              duration: const Duration(milliseconds: 500), // Slowed from 300ms
              curve: Curves.easeOut,
              offset: _showWord ? Offset.zero : const Offset(0, 0.4),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500), // Slowed from 300ms
                curve: Curves.easeOut,
                opacity: _showWord ? 1.0 : 0.0,
                child: Text(
                  'KANAKKAN',
                  style: AppTypography.displayLarge(color: Colors.white).copyWith(
                    letterSpacing: 8,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // The Ledger Line Sweep
            AnimatedContainer(
              duration: const Duration(milliseconds: 500), // Slowed from 320ms
              curve: Curves.easeOut,
              height: 2,
              width: _showLine ? 140 : 0,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
