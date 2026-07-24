import 'package:flutter/foundation.dart';
import 'package:animations_in_flutter/core/constants.dart';
import 'package:animations_in_flutter/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService extends ChangeNotifier {
  static const String _localKey = 'is_premium_user';

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

  bool get canAddTrip => _isPremium;
  bool canAddPhotos(int currentCount) => _isPremium || currentCount < AppConstants.freeMaxPhotosPerTrip;
  bool get canAddCustomCategory => _isPremium;

  String remainingTripsMessage(int currentCount) {
    if (_isPremium) return '';
    final remaining = AppConstants.freeMaxTrips - currentCount;
    if (remaining <= 0) return 'Free plan limited to ${AppConstants.freeMaxTrips} trips. Upgrade to Premium for unlimited.';
    return '$remaining trips remaining on free plan.';
  }

  String remainingPhotosMessage(int currentCount) {
    if (_isPremium) return '';
    final remaining = AppConstants.freeMaxPhotosPerTrip - currentCount;
    if (remaining <= 0) return 'Free plan limited to ${AppConstants.freeMaxPhotosPerTrip} photos per trip. Upgrade to Premium for unlimited.';
    return '$remaining photos remaining.';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_localKey) ?? false;
    _userName = prefs.getString('premium_user_name') ?? '';
    _userEmail = prefs.getString('premium_user_email') ?? '';
    if (_isPremium) notifyListeners();

    final svc = SupabaseService();
    if (svc.isLoggedIn) {
      await _syncFromServer();
    }
  }

  Future<void> _syncFromServer() async {
    final svc = SupabaseService();
    try {
      final data = await svc.client
          .from('user_profiles')
          .select('is_premium, display_name, email')
          .eq('user_id', svc.userId!)
          .maybeSingle();
      if (data != null) {
        final serverPremium = data['is_premium'] as bool? ?? false;
        _isPremium = serverPremium;
        _userName = (data['display_name'] as String?) ?? '';
        _userEmail = (data['email'] as String?) ?? '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_localKey, serverPremium);
        await prefs.setString('premium_user_name', _userName);
        await prefs.setString('premium_user_email', _userEmail);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> activatePremium() async {
    final svc = SupabaseService();
    if (!svc.isLoggedIn) return false;

    try {
      await svc.client.from('user_profiles').upsert({
        'user_id': svc.userId,
        'is_premium': true,
        'display_name': svc.userEmail?.split('@').first ?? '',
        'email': svc.userEmail ?? '',
      });
      _isPremium = true;
      _userName = svc.userEmail?.split('@').first ?? '';
      _userEmail = svc.userEmail ?? '';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_localKey, true);
      await prefs.setString('premium_user_name', _userName);
      await prefs.setString('premium_user_email', _userEmail);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Premium activation error: $e');
      return false;
    }
  }

  Future<void> deactivatePremium() async {
    final svc = SupabaseService();
    if (svc.isLoggedIn) {
      try {
        await svc.client
            .from('user_profiles')
            .update({'is_premium': false})
            .eq('user_id', svc.userId!);
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localKey, false);
    await prefs.remove('premium_user_name');
    await prefs.remove('premium_user_email');
    _isPremium = false;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }
}
