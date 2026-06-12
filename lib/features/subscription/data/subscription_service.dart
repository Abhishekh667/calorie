import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_plan.dart';

enum SubscriptionStatus {
  unknown,
  loading,
  notSubscribed,
  subscribed,
  error,
}

class SubscriptionService {
  static const String _premiumKey = 'is_premium';
  static const String _productId = 'calorie_premium';

  final InAppPurchase _iap = InAppPurchase.instance;
  final List<StreamSubscription> _subscriptions = [];

  SubscriptionStatus _status = SubscriptionStatus.unknown;
  SubscriptionPlan? _selectedPlan;
  List<SubscriptionPlan> _availablePlans = [];
  String? _errorMessage;
  bool _productsAvailable = false;
  bool _restoring = false;

  SubscriptionStatus get status => _status;
  List<SubscriptionPlan> get availablePlans => _availablePlans;
  SubscriptionPlan? get selectedPlan => _selectedPlan;
  bool get isProductsAvailable => _productsAvailable;
  String? get errorMessage => _errorMessage;
  bool get isRestoring => _restoring;

  final ValueNotifier<SubscriptionStatus> statusNotifier = ValueNotifier(SubscriptionStatus.unknown);
  final ValueNotifier<List<SubscriptionPlan>> plansNotifier = ValueNotifier([]);
  final ValueNotifier<SubscriptionPlan?> selectedPlanNotifier = ValueNotifier(null);
  final ValueNotifier<bool> productsAvailableNotifier = ValueNotifier(false);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<bool> restoringNotifier = ValueNotifier(false);

  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
  }

  Future<void> init() async {
    _status = SubscriptionStatus.loading;
    statusNotifier.value = _status;

    final available = await _iap.isAvailable();
    if (!available) {
      _status = SubscriptionStatus.error;
      _errorMessage = 'Google Play Store not available';
      statusNotifier.value = _status;
      errorNotifier.value = _errorMessage;
      return;
    }

    _listenToPurchaseUpdates();

    await _queryProducts();

    await _checkExistingPurchase();
  }

  void _listenToPurchaseUpdates() {
    final purchaseUpdated = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (error) {
        _status = SubscriptionStatus.error;
        _errorMessage = 'Purchase error: $error';
        statusNotifier.value = _status;
        errorNotifier.value = _errorMessage;
      },
    );
    _subscriptions.add(purchaseUpdated);
  }

  Future<void> _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      await _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      await _setPremium(true);
      _status = SubscriptionStatus.subscribed;
      statusNotifier.value = _status;
    } else if (purchase.status == PurchaseStatus.error) {
      _status = SubscriptionStatus.error;
      _errorMessage = purchase.error?.message ?? 'Purchase failed';
      statusNotifier.value = _status;
      errorNotifier.value = _errorMessage;
    } else if (purchase.status == PurchaseStatus.pending) {
      _status = SubscriptionStatus.loading;
      statusNotifier.value = _status;
    } else if (purchase.status == PurchaseStatus.canceled) {
      _status = SubscriptionStatus.notSubscribed;
      statusNotifier.value = _status;
    }
  }

  Future<void> _queryProducts() async {
    final productDetails = await _iap.queryProductDetails({_productId});

    if (productDetails.error != null) {
      _errorMessage = productDetails.error!.message;
      errorNotifier.value = _errorMessage;
    }

    if (productDetails.productDetails.isEmpty) {
      _productsAvailable = false;
      productsAvailableNotifier.value = false;
      _availablePlans = _getMockPlans();
      plansNotifier.value = _availablePlans;
      if (_selectedPlan == null && _availablePlans.isNotEmpty) {
        _selectPlan(_availablePlans[1]);
      }
      _status = SubscriptionStatus.notSubscribed;
      statusNotifier.value = _status;
      return;
    }

    _productsAvailable = true;
    productsAvailableNotifier.value = true;
    _availablePlans = [];

    for (final detail in productDetails.productDetails) {
      if (detail is GooglePlayProductDetails) {
        final plan = _mapToPlan(detail);
        if (plan != null) {
          _availablePlans.add(plan);
        }
      }
    }

    if (_availablePlans.isEmpty) {
      _availablePlans = _getMockPlans();
    }

    plansNotifier.value = _availablePlans;
    if (_selectedPlan == null && _availablePlans.isNotEmpty) {
      _selectPlan(_availablePlans[1]);
    }

    _status = SubscriptionStatus.notSubscribed;
    statusNotifier.value = _status;
  }

  SubscriptionPlan? _mapToPlan(GooglePlayProductDetails detail) {
    final offerDetails = detail.productDetails.subscriptionOfferDetails;
    if (offerDetails == null || detail.subscriptionIndex == null) return null;

    final idx = detail.subscriptionIndex!;
    if (idx >= offerDetails.length) return null;

    final offer = offerDetails[idx];
    final basePlanId = offer.basePlanId;
    final pricingPhases = offer.pricingPhases;
    if (pricingPhases.isEmpty) return null;

    final firstPhase = pricingPhases.first;
    final period = firstPhase.billingPeriod;

    String title;
    String displayPrice;
    String periodLabel;
    double rawPrice;
    bool isBestValue = false;
    SubscriptionPeriod subPeriod;

    if (basePlanId.contains('weekly') || period.contains('P1W') || period.contains('7D')) {
      title = 'Weekly';
      displayPrice = '₹29';
      periodLabel = '/week';
      rawPrice = 29;
      subPeriod = SubscriptionPeriod.weekly;
    } else if (basePlanId.contains('monthly') || period.contains('P1M') || period.contains('30D') || period.contains('1M')) {
      title = 'Monthly';
      displayPrice = '₹79';
      periodLabel = '/month';
      rawPrice = 79;
      subPeriod = SubscriptionPeriod.monthly;
    } else if (basePlanId.contains('quarterly') || period.contains('P3M') || period.contains('90D') || period.contains('3M')) {
      title = '3 Months';
      displayPrice = '₹109';
      periodLabel = '/3 months';
      rawPrice = 109;
      subPeriod = SubscriptionPeriod.quarterly;
      isBestValue = true;
    } else {
      return null;
    }

    return SubscriptionPlan(
      id: detail.id,
      basePlanId: basePlanId,
      title: title,
      displayPrice: displayPrice,
      periodLabel: periodLabel,
      rawPrice: rawPrice,
      period: subPeriod,
      isBestValue: isBestValue,
      offerToken: offer.offerIdToken,
    );
  }

  List<SubscriptionPlan> _getMockPlans() {
    return [
      const SubscriptionPlan(
        id: 'mock_weekly',
        basePlanId: 'weekly-29',
        title: 'Weekly',
        displayPrice: '₹29',
        periodLabel: '/week',
        rawPrice: 29,
        period: SubscriptionPeriod.weekly,
      ),
      const SubscriptionPlan(
        id: 'mock_monthly',
        basePlanId: 'monthly-79',
        title: 'Monthly',
        displayPrice: '₹79',
        periodLabel: '/month',
        rawPrice: 79,
        period: SubscriptionPeriod.monthly,
      ),
      SubscriptionPlan(
        id: 'mock_quarterly',
        basePlanId: 'quarterly-109',
        title: '3 Months',
        displayPrice: '₹109',
        periodLabel: '/3 months',
        rawPrice: 109,
        period: SubscriptionPeriod.quarterly,
        isBestValue: true,
      ),
    ];
  }

  void selectPlan(SubscriptionPlan plan) {
    _selectPlan(plan);
  }

  void _selectPlan(SubscriptionPlan plan) {
    _selectedPlan = plan;
    selectedPlanNotifier.value = plan;
  }

  Future<bool> purchase() async {
    if (_selectedPlan == null) return false;

    if (!_productsAvailable) {
      _errorMessage = 'Subscription products are not available. Please check Play Console setup.';
      errorNotifier.value = _errorMessage;
      return false;
    }

    _status = SubscriptionStatus.loading;
    statusNotifier.value = _status;

    final productDetails = await _iap.queryProductDetails({_productId});
    if (productDetails.productDetails.isEmpty) {
      _status = SubscriptionStatus.error;
      _errorMessage = 'Subscription products not available';
      statusNotifier.value = _status;
      errorNotifier.value = _errorMessage;
      return false;
    }

    GooglePlayProductDetails? selectedDetail;
    for (final detail in productDetails.productDetails) {
      if (detail is GooglePlayProductDetails && detail.offerToken == _selectedPlan!.offerToken) {
        selectedDetail = detail;
        break;
      }
    }

    if (selectedDetail == null) {
      _status = SubscriptionStatus.error;
      _errorMessage = 'Selected plan not found';
      statusNotifier.value = _status;
      errorNotifier.value = _errorMessage;
      return false;
    }

    final purchaseParam = GooglePlayPurchaseParam(
      productDetails: selectedDetail,
      offerToken: selectedDetail.offerToken,
    );

    final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    if (!result) {
      _status = SubscriptionStatus.error;
      _errorMessage = 'Purchase failed to start';
      statusNotifier.value = _status;
      errorNotifier.value = _errorMessage;
      return false;
    }

    return true;
  }

  Future<void> restorePurchases() async {
    _restoring = true;
    restoringNotifier.value = true;

    await _iap.restorePurchases();

    await Future.delayed(const Duration(milliseconds: 500));

    final isPrem = await _getPremium();
    if (isPrem) {
      _status = SubscriptionStatus.subscribed;
      statusNotifier.value = _status;
    } else {
      _status = SubscriptionStatus.notSubscribed;
      statusNotifier.value = _status;
    }

    _restoring = false;
    restoringNotifier.value = false;
  }

  Future<void> _checkExistingPurchase() async {
    final isPrem = await _getPremium();
    if (isPrem) {
      _status = SubscriptionStatus.subscribed;
      statusNotifier.value = _status;
    }
  }

  void manageSubscription(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Manage Subscription'),
        content: const Text(
          'You can manage or cancel your subscription anytime from the Google Play Store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _getPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  Future<void> _setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
  }

  Future<bool> isPremium() async {
    if (_status == SubscriptionStatus.subscribed) return true;
    return _getPremium();
  }
}
