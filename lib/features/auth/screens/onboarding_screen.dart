import 'package:flutter/material.dart';
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

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final mainBal = double.tryParse(_mainController.text) ?? 0.0;
    final cashBal = double.tryParse(_cashController.text) ?? 0.0;
    final savingsBal = double.tryParse(_savingsController.text) ?? 0.0;

    await SupabaseService.setupInitialWallets(cashBal, mainBal, savingsBal);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AppShell(onLogout: () {})),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Let\'s setup your wallets',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your current balances to get started.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _mainController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Main Bank Balance (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cash in Hand (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _savingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Savings Balance (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.savings),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('Finish Setup', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
