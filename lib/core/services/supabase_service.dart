import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/transaction.dart';

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
  static Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final user = currentUser;
      final query = client.from('transactions').select();
      final response = user != null
          ? await query.eq('user_id', user.id).order('created_at', ascending: false)
          : await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase fetch transactions error: $e');
      return [];
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