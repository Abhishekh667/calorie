import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/premium_service.dart';

final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService();
});

final isPremiumProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(premiumServiceProvider);
  return service.isPremium();
});
