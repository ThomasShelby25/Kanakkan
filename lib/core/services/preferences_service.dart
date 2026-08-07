import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
