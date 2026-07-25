import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:animations_in_flutter/core/constants.dart';
import 'package:animations_in_flutter/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'iap_service.dart';

class PremiumService extends ChangeNotifier {
  static const String _localKey = 'is_premium_user';
  static const String _purchaseIdKey = 'premium_purchase_id';

  bool _isPremium = false;
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = false;
  StreamSubscription<PurchaseStatus>? _purchaseSub;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
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

    await IapService().initialize();

    final svc = SupabaseService();
    if (svc.isLoggedIn) {
      _userName = svc.userEmail?.split('@').first ?? _userName;
      _userEmail = svc.userEmail ?? _userEmail;
    }

    _purchaseSub = IapService().purchaseStream.listen((status) {
      if (status == PurchaseStatus.purchased || status == PurchaseStatus.restored) {
        _activateLocal();
      }
    });

    await _verifyExistingPurchase();
  }

  Future<void> _verifyExistingPurchase() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_purchaseIdKey);
    if (savedId != null) {
      _isPremium = true;
      notifyListeners();
      return;
    }
    await IapService().restorePurchases();
  }

  void _activateLocal() async {
    _isPremium = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localKey, true);
    final svc = SupabaseService();
    _userName = svc.userEmail?.split('@').first ?? _userName;
    _userEmail = svc.userEmail ?? _userEmail;
    await prefs.setString('premium_user_name', _userName);
    await prefs.setString('premium_user_email', _userEmail);
    notifyListeners();
    await _syncToServer(true);
  }

  Future<void> _syncToServer(bool premium) async {
    final svc = SupabaseService();
    if (!svc.isLoggedIn) return;
    try {
      await svc.client.from('user_profiles').upsert({
        'user_id': svc.userId,
        'is_premium': premium,
        'display_name': _userName,
        'email': _userEmail,
      });
    } catch (_) {}
  }

  Future<bool> buyPremium() async {
    _isLoading = true;
    notifyListeners();

    final iap = IapService();
    if (iap.product == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final success = await iap.buyPremium();
    if (!success) {
      _isLoading = false;
      notifyListeners();
    }
    return success;
  }

  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();
    await IapService().restorePurchases();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localKey, false);
    await prefs.remove(_purchaseIdKey);
    await prefs.remove('premium_user_name');
    await prefs.remove('premium_user_email');
    _isPremium = false;
    _userName = '';
    _userEmail = '';
    await _syncToServer(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
