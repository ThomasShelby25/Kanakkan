import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/finance_provider.dart';
import 'core/widgets/app_shell.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';

import 'core/services/supabase_service.dart';
import 'core/services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize();
    await PreferencesService.init();
  } catch (e) {
    debugPrint('Supabase initialization note: $e');
  }

  // Make both status bar and navigation bar transparent for edge-to-edge design
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    ChangeNotifierProvider(
      create: (_) => FinanceProvider()..initTheme(),
      child: const KanakkanApp(),
    ),
  );
}

class KanakkanApp extends StatefulWidget {
  const KanakkanApp({super.key});

  @override
  State<KanakkanApp> createState() => _KanakkanAppState();
}

class _KanakkanAppState extends State<KanakkanApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<FinanceProvider>().isDarkTheme;

    return MaterialApp(
      title: 'KANAKKAN',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final VoidCallback onLogout;
  const AuthWrapper({super.key, required this.onLogout});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkWallets();
  }

  Future<void> _checkWallets() async {
    final wallets = await SupabaseService.getWallets();
    if (mounted) {
      setState(() {
        _needsOnboarding = wallets.isEmpty;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_needsOnboarding) {
      return const OnboardingScreen();
    }
    return AppShell(onLogout: widget.onLogout);
  }
}

