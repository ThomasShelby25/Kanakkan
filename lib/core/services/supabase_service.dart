import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/budget.dart';

import 'dart:io';

class SupabaseService {
  static const String supabaseUrl = 'https://vemaqpsqjmsqggrnntcz.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlbWFxcHNxam1zcWdncm5udGN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU3MzM0NTksImV4cCI6MjEwMTMwOTQ1OX0.djMZal-PCfqssc5fiRz_TSF14Efafm1Enzfi5CH95Y0';

  // Web OAuth Client ID (from Google Cloud Console)
  static const String _webClientId =
      '429351586587-7tu1egd5f3g4i0rr87rf5gneg6mo225v.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _webClientId : null,
    serverClientId: kIsWeb ? null : _webClientId,
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Current User Helpers
  static User? get currentUser => client.auth.currentUser;

  static Future<void> updateProfile({required String name, required String phone, String? avatarUrl}) async {
    try {
      final updates = {
        'display_name': name,
        'phone_number': phone,
      };
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }
      
      await client.auth.updateUser(
        UserAttributes(data: updates),
      );
    } catch (e) {
      debugPrint('Failed to update profile: $e');
    }
  }

  static Future<String?> uploadAvatar(File imageFile) async {
    try {
      final user = currentUser;
      if (user == null) return null;
      
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      await client.storage.from('avatars').upload(fileName, imageFile);
      
      final publicUrl = client.storage.from('avatars').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Avatar upload failed: $e');
      return null;
    }
  }

  static String get userEmail => currentUser?.email ?? 'User';
  static String get userName {
    final email = currentUser?.email;
    if (email != null && email.contains('@')) {
      final namePart = email.split('@').first;
      return namePart[0].toUpperCase() + namePart.substring(1);
    }
    return 'User';
  }

  // Auth Operations
  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await client.auth.signOut();
  }

  // Native Google Sign-In → exchanges ID token with Supabase
  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // On web, use Supabase's built-in OAuth flow (handles popups automatically)
        final success = await client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'http://localhost:5000',
        );
        if (!success) throw Exception('Google OAuth flow failed to launch.');
        return null; // The auth state listener in login_screen will handle the success
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google ID token is null');
      }

      return await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  // Database Operations - Transactions
  static Future<List<Map<String, dynamic>>> getTransactions({int limit = 50, int offset = 0}) async {
    try {
      final user = currentUser;
      final query = client.from('transactions').select();
      final response = user != null
          ? await query.eq('user_id', user.id).order('created_at', ascending: false).range(offset, offset + limit - 1)
          : await query.order('created_at', ascending: false).range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase fetch transactions error: $e');
      return [];
    }
  }

  // Database Operations - Wallets
  static Future<List<WalletModel>> getWallets() async {
    try {
      final user = currentUser;
      if (user == null) return [];
      final response = await client.from('wallets').select().eq('user_id', user.id).order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response).map((e) => WalletModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Supabase fetch wallets error: $e');
      return [];
    }
  }

  static Future<WalletModel?> createWallet(WalletModel wallet) async {
    try {
      final user = currentUser;
      if (user == null) return null;
      final response = await client.from('wallets').insert({
        'user_id': user.id,
        'name': wallet.name,
        'opening_balance': wallet.openingBalance,
        'balance_set_at': wallet.balanceSetAt?.toIso8601String(),
        'icon_code': 0xe041, // default icon
        'is_dark': wallet.isDark,
      }).select().single();
      return WalletModel.fromJson(response);
    } catch (e) {
      debugPrint('Supabase create wallet error: $e');
      return null;
    }
  }

  static Future<void> updateWallet(WalletModel wallet) async {
    try {
      await client.from('wallets').update({
        'name': wallet.name,
        'opening_balance': wallet.openingBalance,
        'balance_set_at': wallet.balanceSetAt?.toIso8601String(),
      }).eq('id', wallet.id);
    } catch (e) {
      debugPrint('Supabase update wallet error: $e');
    }
  }

  static Future<void> deleteWallet(String id) async {
    try {
      await client.from('wallets').delete().eq('id', id);
    } catch (e) {
      debugPrint('Supabase delete wallet error: $e');
    }
  }

  // Database Operations - Budgets
  static Future<List<BudgetModel>> getBudgets() async {
    try {
      final user = currentUser;
      if (user == null) return [];
      final response = await client.from('budgets').select().eq('user_id', user.id);
      return List<Map<String, dynamic>>.from(response).map((e) => BudgetModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Supabase fetch budgets error: $e');
      return [];
    }
  }

  static Future<void> upsertBudget(BudgetModel budget) async {
    try {
      final user = currentUser;
      if (user == null) return;
      
      await client.from('budgets').upsert({
        'user_id': user.id,
        'category': budget.category,
        'limit_amount': budget.limitAmount,
      }, onConflict: 'user_id, category');
    } catch (e) {
      debugPrint('Supabase upsert budget error: $e');
    }
  }

  static Future<void> setupInitialWallets(double cash, double main, double savings) async {
    try {
      final user = currentUser;
      if (user == null) return;
      
      final timestamp = DateTime.now().toIso8601String();
      
      final walletsToInsert = [
        {
          'user_id': user.id,
          'name': 'Cash',
          'opening_balance': cash,
          'balance_set_at': timestamp,
          'icon_code': Icons.payments.codePoint,
          'is_dark': false,
        },
        {
          'user_id': user.id,
          'name': 'Main',
          'opening_balance': main,
          'balance_set_at': timestamp,
          'icon_code': Icons.account_balance.codePoint,
          'is_dark': true,
        },
        {
          'user_id': user.id,
          'name': 'Savings',
          'opening_balance': savings,
          'balance_set_at': timestamp,
          'icon_code': Icons.savings.codePoint,
          'is_dark': false,
        }
      ];

      await client.from('wallets').insert(walletsToInsert);
    } catch (e) {
      debugPrint('Supabase setup initial wallets error: $e');
    }
  }

  // Database Operations - RPC
  static Future<double> getNetBalance() async {
    try {
      final user = currentUser;
      if (user == null) return 0.0;
      final response = await client.rpc('get_user_net_balance', params: {'p_user_id': user.id});
      return (response is num) ? response.toDouble() : double.tryParse(response.toString()) ?? 0.0;
    } catch (e) {
      debugPrint('Supabase RPC net balance error: $e');
      return 0.0;
    }
  }

  

static Future<void> createTransaction(TransactionModel tx) async {
    try {
      final user = currentUser;
      await client.from('transactions').insert({
        'note': tx.title,
        'amount': tx.amount,
        'category': tx.category,
        'type': tx.type == TransactionType.expense ? 'expense' : 'income',
        'created_at': tx.date.toIso8601String(),
        if (user != null) 'user_id': user.id,
      });
    } catch (e) {
      debugPrint('Supabase insert transaction error: $e');
    }
  }
}