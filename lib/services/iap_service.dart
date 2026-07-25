import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IapService {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  static const String premiumProductId = 'trip_recorder_premium';
  static const String _purchaseIdKey = 'premium_purchase_id';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  ProductDetails? _product;
  ProductDetails? get product => _product;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  bool _isInitialized = false;

  final _purchaseController = StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  String get displayPrice => _product?.price ?? '';

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription?.cancel();
        _subscription = null;
      },
      onError: (error) => debugPrint('IAP stream error: $error'),
    );

    final response = await _iap.queryProductDetails({premiumProductId});
    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
    }
    _isInitialized = true;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _purchaseController.add(purchase);
    }
  }

  Future<bool> handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_purchaseIdKey, purchase.productID);
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return true;
    }

    if (purchase.status == PurchaseStatus.error) {
      debugPrint('IAP error: ${(purchase.error as Object?)}');
    }

    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
    return false;
  }

  Future<bool> buyPremium() async {
    if (_product == null || !_isAvailable) return false;

    final success = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: _product!),
    );
    return success;
  }

  Future<List<PurchaseDetails>> restorePurchases() async {
    final restored = <PurchaseDetails>[];

    final sub = _iap.purchaseStream.listen((purchases) {
      for (final p in purchases) {
        if (p.status == PurchaseStatus.restored) {
          restored.add(p);
        }
      }
    });

    await _iap.restorePurchases();
    await Future.delayed(const Duration(seconds: 2));
    await sub.cancel();

    for (final p in restored) {
      await handlePurchase(p);
    }

    return restored;
  }

  Future<bool> hasSavedPurchase() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_purchaseIdKey);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _purchaseController.close();
  }
}
