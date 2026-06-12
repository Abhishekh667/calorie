import 'food_entry.dart';
import 'water_entry.dart';
import 'weight_entry.dart';

class DailyLog {
  final DateTime date;
  final List<FoodEntry> foodEntries;
  final List<WaterEntry> waterEntries;
  final WeightEntry? weightEntry;

  DailyLog({
    required this.date,
    this.foodEntries = const [],
    this.waterEntries = const [],
    this.weightEntry,
  });

  double get totalCalories =>
      foodEntries.fold(0, (sum, e) => sum + e.calories);

  double get totalProtein =>
      foodEntries.fold(0, (sum, e) => sum + e.protein);

  double get totalCarbs =>
      foodEntries.fold(0, (sum, e) => sum + e.carbs);

  double get totalFat =>
      foodEntries.fold(0, (sum, e) => sum + e.fat);

  double get totalWaterMl =>
      waterEntries.fold(0, (sum, e) => sum + e.amountMl);

  Map<String, List<FoodEntry>> get mealsByType {
    final map = <String, List<FoodEntry>>{};
    for (final entry in foodEntries) {
      map.putIfAbsent(entry.mealType, () => []);
      map[entry.mealType]!.add(entry);
    }
    return map;
  }
}
