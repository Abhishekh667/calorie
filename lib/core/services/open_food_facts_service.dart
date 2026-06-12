import '../models/food_item.dart';
import 'api_service.dart';

class OpenFoodFactsService {
  final ApiService _api = ApiService();

  Future<FoodItem?> lookupBarcode(String barcode) async {
    final data = await _api.getFoodByBarcode(barcode);
    return _parseProduct(data);
  }

  FoodItem? _parseProduct(Map<String, dynamic> data) {
    try {
      if (data.containsKey('error')) return null;
      if (data['status'] != 1) return null;

      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      final nutriments =
          product['nutriments'] as Map<String, dynamic>? ?? {};

      final name = product['product_name'] as String? ?? 'Unknown Product';
      final brand = product['brands'] as String? ?? '';
      final code = product['code'] as String? ?? '';

      final energy =
          _getDouble(nutriments['energy-kcal_100g']) ??
          _getDouble(nutriments['energy_100g']) ??
          0;
      final protein = _getDouble(nutriments['proteins_100g']) ?? 0;
      final carbs = _getDouble(nutriments['carbohydrates_100g']) ?? 0;
      final fat = _getDouble(nutriments['fat_100g']) ?? 0;
      final fiber = _getDouble(nutriments['fiber_100g']) ?? 0;
      final sugar = _getDouble(nutriments['sugars_100g']) ?? 0;
      final servingSizeG = _getDouble(product['serving_size']) ?? 100;

      return FoodItem(
        id: 'off_$code',
        name: name,
        brand: brand,
        servingSizeG: servingSizeG,
        calories: energy,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: fiber,
        sugar: sugar,
        barcode: code,
      );
    } catch (_) {
      return null;
    }
  }

  double? _getDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
      final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned);
    }
    return null;
  }
}
