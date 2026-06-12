import 'food_item.dart';

class FoodEntry {
  final String id;
  final String foodItemId;
  final String mealType;
  final DateTime date;
  final double servings;
  final FoodItem foodItem;

  FoodEntry({
    required this.id,
    required this.foodItemId,
    required this.mealType,
    required this.date,
    required this.servings,
    required this.foodItem,
  });

  double get calories => foodItem.calories * servings / foodItem.servingSizeG;
  double get protein => foodItem.protein * servings / foodItem.servingSizeG;
  double get carbs => foodItem.carbs * servings / foodItem.servingSizeG;
  double get fat => foodItem.fat * servings / foodItem.servingSizeG;
  double get servingGram => servings;

  FoodEntry copyWith({
    String? id,
    String? foodItemId,
    String? mealType,
    DateTime? date,
    double? servings,
    FoodItem? foodItem,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      foodItemId: foodItemId ?? this.foodItemId,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,
      servings: servings ?? this.servings,
      foodItem: foodItem ?? this.foodItem,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'foodItemId': foodItemId,
        'mealType': mealType,
        'date': date.toIso8601String(),
        'servings': servings,
        'foodItem': foodItem.toJson(),
      };

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
        id: json['id'] as String,
        foodItemId: json['foodItemId'] as String,
        mealType: json['mealType'] as String,
        date: DateTime.parse(json['date'] as String),
        servings: (json['servings'] as num).toDouble(),
        foodItem: FoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
      );
}
