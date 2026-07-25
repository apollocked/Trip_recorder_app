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

  final _purchaseController = StreamController<PurchaseStatus>.broadcast();
  Stream<PurchaseStatus> get purchaseStream => _purchaseController.stream;

  String get displayPrice => _product?.price ?? '';

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('IAP stream error: $error'),
    );

    final response = await _iap.queryProductDetails({premiumProductId});
    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_purchaseIdKey, purchase.productID);
      _purchaseController.add(PurchaseStatus.purchased);
    } else if (purchase.status == PurchaseStatus.error) {
      _purchaseController.add(PurchaseStatus.error);
    } else if (purchase.status == PurchaseStatus.canceled) {
      _purchaseController.add(PurchaseStatus.canceled);
    }

    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  Future<bool> buyPremium() async {
    if (_product == null || !_isAvailable) return false;
    final param = PurchaseParam(productDetails: _product!);
    final success = await _iap.buyNonConsumable(purchaseParam: param);
    return success;
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}
