import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Initial Wallet Balances ---
  static const String _keyInitialMain = 'initial_main_balance';
  static const String _keyInitialSavings = 'initial_savings_balance';
  static const String _keyInitialCash = 'initial_cash_balance';

  static double get initialMainBalance => _prefs.getDouble(_keyInitialMain) ?? 0.0;
  static Future<void> setInitialMainBalance(double value) async {
    await _prefs.setDouble(_keyInitialMain, value);
  }

  static double get initialSavingsBalance => _prefs.getDouble(_keyInitialSavings) ?? 0.0;
  static Future<void> setInitialSavingsBalance(double value) async {
    await _prefs.setDouble(_keyInitialSavings, value);
  }

  static double get initialCashBalance => _prefs.getDouble(_keyInitialCash) ?? 0.0;
  static Future<void> setInitialCashBalance(double value) async {
    await _prefs.setDouble(_keyInitialCash, value);
  }

  // --- Balance Tracking Start Date ---
  // Only transactions AFTER this date affect the balance calculation.
  static const String _keyBalanceSetAt = 'balance_set_at_ms';

  static DateTime? get balanceSetAt {
    final ms = _prefs.getInt(_keyBalanceSetAt);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  /// Call this whenever the user sets/updates their initial balance.
  static Future<void> recordBalanceSetNow() async {
    await _prefs.setInt(_keyBalanceSetAt, DateTime.now().millisecondsSinceEpoch);
  }

  // --- Theme & Notifications ---
  static const String _keyDarkTheme = 'dark_theme_enabled';
  static const String _keyPushNotifications = 'push_notifications_enabled';

  static bool get isDarkTheme => _prefs.getBool(_keyDarkTheme) ?? false;
  static Future<void> setDarkTheme(bool value) async {
    await _prefs.setBool(_keyDarkTheme, value);
  }

  static bool get pushNotificationsEnabled => _prefs.getBool(_keyPushNotifications) ?? true;
  static Future<void> setPushNotificationsEnabled(bool value) async {
    await _prefs.setBool(_keyPushNotifications, value);
  }
}
