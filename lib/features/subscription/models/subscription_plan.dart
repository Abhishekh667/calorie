import 'package:flutter/material.dart';

enum SubscriptionPeriod { weekly, monthly, quarterly }

class SubscriptionPlan {
  final String id;
  final String basePlanId;
  final String title;
  final String displayPrice;
  final String periodLabel;
  final double rawPrice;
  final SubscriptionPeriod period;
  final bool isBestValue;
  final String? offerToken;

  const SubscriptionPlan({
    required this.id,
    required this.basePlanId,
    required this.title,
    required this.displayPrice,
    required this.periodLabel,
    required this.rawPrice,
    required this.period,
    this.isBestValue = false,
    this.offerToken,
  });

  String get subtitle {
    switch (period) {
      case SubscriptionPeriod.weekly:
        return 'Best for trying';
      case SubscriptionPeriod.monthly:
        return 'Most popular';
      case SubscriptionPeriod.quarterly:
        return 'Best value';
    }
  }

  Color get accentColor {
    switch (period) {
      case SubscriptionPeriod.weekly:
        return Colors.blue;
      case SubscriptionPeriod.monthly:
        return Colors.green;
      case SubscriptionPeriod.quarterly:
        return Colors.orange;
    }
  }
}
