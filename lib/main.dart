import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/finance_provider.dart';
import 'core/widgets/app_shell.dart';
import 'features/auth/screens/login_screen.dart';

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

  // Hide the Android system navigation bar (fullscreen immersive mode)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    ChangeNotifierProvider(
      create: (_) => FinanceProvider()..initTheme(),
      child: const FinanceFlowApp(),
    ),
  );
}


class FinanceFlowApp extends StatefulWidget {
  const FinanceFlowApp({super.key});

  @override
  State<FinanceFlowApp> createState() => _FinanceFlowAppState();
}

class _FinanceFlowAppState extends State<FinanceFlowApp> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = SupabaseService.client.auth.currentSession != null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<FinanceProvider>().isDarkTheme;

    return MaterialApp(
      title: 'FinanceFlow',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: _isLoggedIn
          ? AppShell(
              onLogout: () async {
                await SupabaseService.signOut();
                setState(() {
                  _isLoggedIn = false;
                });
              },
            )
          : LoginScreen(
              onLoginSuccess: () {
                setState(() {
                  _isLoggedIn = true;
                });
              },
            ),
    );
  }
}

