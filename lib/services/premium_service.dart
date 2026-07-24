import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService extends ChangeNotifier {
  static const String _key = 'is_premium_user';
  static const String _nameKey = 'premium_user_name';
  static const String _emailKey = 'premium_user_email';

  bool _isPremium = false;
  String _userName = '';
  String _userEmail = '';

  bool get isPremium => _isPremium;
  String get userName => _userName;
  String get userEmail => _userEmail;

  String get initials {
    if (_userName.isEmpty) return '?';
    final parts = _userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_key) ?? false;
    _userName = prefs.getString(_nameKey) ?? '';
    _userEmail = prefs.getString(_emailKey) ?? '';
    notifyListeners();
  }

  Future<void> activatePremium({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    _isPremium = true;
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  Future<void> deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    _isPremium = false;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }
}
