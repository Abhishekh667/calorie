import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/subscription/presentation/paywall_screen.dart';

class PremiumService {
  static PremiumService? _instance;
  factory PremiumService() => _instance ??= PremiumService._();
  PremiumService._();

  static const String _premiumKey = 'is_premium';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isPremium() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_premiumKey) ?? false;
  }

  Future<void> setPremium(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_premiumKey, value);
  }

  static Future<void> requirePremium(BuildContext context, String featureName) async {
    final service = PremiumService();
    final isPrem = await service.isPremium();
    if (!isPrem && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
    }
  }
}
