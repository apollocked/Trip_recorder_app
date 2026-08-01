import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:animations_in_flutter/core/constants.dart';
import 'package:animations_in_flutter/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'iap_service.dart';
import 'theme_service.dart';

class PremiumService extends ChangeNotifier {
  static const String _localKey = 'is_premium_user';
  static const String _purchaseIdKey = 'premium_purchase_id';

  bool _isPremium = false;
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = false;
  String? _error;
  StreamSubscription<PurchaseDetails>? _purchaseSub;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String? get error => _error;
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
  bool canAddTripWithCount(int currentCount) =>
      _isPremium || currentCount < AppConstants.freeMaxTrips;
  bool canAddPhotos(int currentCount) =>
      _isPremium || currentCount < AppConstants.freeMaxPhotosPerTrip;
  bool get canAddCustomCategory => _isPremium;

  String remainingTripsMessage(int currentCount) {
    if (_isPremium) return '';
    final remaining = AppConstants.freeMaxTrips - currentCount;
    if (remaining <= 0) {
      return 'Free plan limited to ${AppConstants.freeMaxTrips} trips. Upgrade to Premium for unlimited.';
    }
    return '$remaining trips remaining on free plan.';
  }

  String remainingPhotosMessage(int currentCount) {
    if (_isPremium) return '';
    final remaining = AppConstants.freeMaxPhotosPerTrip - currentCount;
    if (remaining <= 0) {
      return 'Free plan limited to ${AppConstants.freeMaxPhotosPerTrip} photos per trip. Upgrade to Premium for unlimited.';
    }
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

    _purchaseSub = IapService().purchaseStream.listen((purchase) async {
      final success = await IapService().handlePurchase(purchase);
      if (success) {
        _activateLocal();
      } else if (purchase.status == PurchaseStatus.error) {
        _error = 'Purchase failed. Please try again.';
        _isLoading = false;
        notifyListeners();
      } else if (purchase.status == PurchaseStatus.canceled) {
        _isLoading = false;
        notifyListeners();
      } else if (purchase.status == PurchaseStatus.pending) {
        _error = null;
        notifyListeners();
      }
    });

    await _verifyExistingPurchase();
  }

  Future<void> _verifyExistingPurchase() async {
    final hasLocal = await IapService().hasSavedPurchase();
    if (hasLocal) {
      _isPremium = true;
      notifyListeners();
      return;
    }

    final restored = await IapService().restorePurchases();
    if (restored.isNotEmpty) {
      _isPremium = true;
      notifyListeners();
    }
  }

  void _activateLocal() async {
    _isPremium = true;
    _isLoading = false;
    _error = null;
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
    _error = null;
    notifyListeners();

    final iap = IapService();

    if (!iap.isAvailable) {
      _isLoading = false;
      _error = 'Store not available. Check your connection.';
      notifyListeners();
      return false;
    }

    if (iap.product == null) {
      _isLoading = false;
      _error = 'Product not found. Please try again.';
      notifyListeners();
      return false;
    }

    final initiated = await iap.buyPremium();
    if (!initiated) {
      _isLoading = false;
      _error = 'Could not start purchase. Please try again.';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<bool> restorePurchases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final restored = await IapService().restorePurchases();
      if (restored.isNotEmpty) {
        _isPremium = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = 'No previous purchase found.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Restore failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
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
    if (ThemeService.isPremiumTheme(prefs.getString(ThemeService.premiumThemeKey) ?? 'default')) {
      await ThemeService(prefs: prefs).setPremiumTheme('default');
    }
    await _syncToServer(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
