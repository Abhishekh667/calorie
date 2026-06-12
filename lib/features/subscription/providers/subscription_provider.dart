import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/subscription_service.dart';
import '../models/subscription_plan.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final service = SubscriptionService();
  ref.onDispose(() => service.dispose());
  return service;
});

final subscriptionStatusProvider = StateNotifierProvider<SubscriptionStatusNotifier, SubscriptionStatus>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionStatusNotifier(service);
});

class SubscriptionStatusNotifier extends StateNotifier<SubscriptionStatus> {
  final SubscriptionService _service;

  SubscriptionStatusNotifier(this._service) : super(SubscriptionStatus.unknown) {
    state = _service.status;
    _service.statusNotifier.addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    state = _service.status;
  }

  @override
  void dispose() {
    _service.statusNotifier.removeListener(_onStatusChanged);
    super.dispose();
  }
}

final subscriptionPlansProvider = StateNotifierProvider<SubscriptionPlansNotifier, List<SubscriptionPlan>>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionPlansNotifier(service);
});

class SubscriptionPlansNotifier extends StateNotifier<List<SubscriptionPlan>> {
  final SubscriptionService _service;

  SubscriptionPlansNotifier(this._service) : super([]) {
    state = _service.availablePlans;
    _service.plansNotifier.addListener(_onPlansChanged);
  }

  void _onPlansChanged() {
    state = List.from(_service.availablePlans);
  }

  @override
  void dispose() {
    _service.plansNotifier.removeListener(_onPlansChanged);
    super.dispose();
  }
}

final selectedPlanProvider = StateNotifierProvider<SelectedPlanNotifier, SubscriptionPlan?>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SelectedPlanNotifier(service);
});

class SelectedPlanNotifier extends StateNotifier<SubscriptionPlan?> {
  final SubscriptionService _service;

  SelectedPlanNotifier(this._service) : super(null) {
    state = _service.selectedPlan;
    _service.selectedPlanNotifier.addListener(_onSelectedChanged);
  }

  void select(SubscriptionPlan plan) {
    _service.selectPlan(plan);
  }

  void _onSelectedChanged() {
    state = _service.selectedPlan;
  }

  @override
  void dispose() {
    _service.selectedPlanNotifier.removeListener(_onSelectedChanged);
    super.dispose();
  }
}

final productsAvailableProvider = StateNotifierProvider<ProductsAvailableNotifier, bool>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return ProductsAvailableNotifier(service);
});

class ProductsAvailableNotifier extends StateNotifier<bool> {
  final SubscriptionService _service;

  ProductsAvailableNotifier(this._service) : super(false) {
    state = _service.isProductsAvailable;
    _service.productsAvailableNotifier.addListener(_onChanged);
  }

  void _onChanged() {
    state = _service.isProductsAvailable;
  }

  @override
  void dispose() {
    _service.productsAvailableNotifier.removeListener(_onChanged);
    super.dispose();
  }
}

final subscriptionErrorProvider = StateNotifierProvider<SubscriptionErrorNotifier, String?>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionErrorNotifier(service);
});

class SubscriptionErrorNotifier extends StateNotifier<String?> {
  final SubscriptionService _service;

  SubscriptionErrorNotifier(this._service) : super(null) {
    state = _service.errorMessage;
    _service.errorNotifier.addListener(_onChanged);
  }

  void _onChanged() {
    state = _service.errorMessage;
  }

  void clear() {
    _service.errorNotifier.value = null;
    state = null;
  }

  @override
  void dispose() {
    _service.errorNotifier.removeListener(_onChanged);
    super.dispose();
  }
}

final isRestoringProvider = StateNotifierProvider<IsRestoringNotifier, bool>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return IsRestoringNotifier(service);
});

class IsRestoringNotifier extends StateNotifier<bool> {
  final SubscriptionService _service;

  IsRestoringNotifier(this._service) : super(false) {
    state = _service.isRestoring;
    _service.restoringNotifier.addListener(_onChanged);
  }

  void _onChanged() {
    state = _service.isRestoring;
  }

  @override
  void dispose() {
    _service.restoringNotifier.removeListener(_onChanged);
    super.dispose();
  }
}

final isSubscribedProvider = Provider<bool>((ref) {
  final status = ref.watch(subscriptionStatusProvider);
  return status == SubscriptionStatus.subscribed;
});
