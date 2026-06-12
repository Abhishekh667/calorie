class FoodItem {
  final String id;
  final String name;
  final String brand;
  final double servingSizeG;
  final double servingSizeLabel;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final String barcode;
  final bool isFavorite;

  FoodItem({
    required this.id,
    required this.name,
    this.brand = '',
    this.servingSizeG = 100,
    this.servingSizeLabel = 100,
    this.servingUnit = 'g',
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.barcode = '',
    this.isFavorite = false,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? brand,
    double? servingSizeG,
    double? servingSizeLabel,
    String? servingUnit,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    String? barcode,
    bool? isFavorite,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      servingSizeG: servingSizeG ?? this.servingSizeG,
      servingSizeLabel: servingSizeLabel ?? this.servingSizeLabel,
      servingUnit: servingUnit ?? this.servingUnit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      barcode: barcode ?? this.barcode,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'servingSizeG': servingSizeG,
        'servingSizeLabel': servingSizeLabel,
        'servingUnit': servingUnit,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
        'barcode': barcode,
        'isFavorite': isFavorite,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as String,
        name: json['name'] as String,
        brand: json['brand'] as String? ?? '',
        servingSizeG: (json['servingSizeG'] as num?)?.toDouble() ?? 100,
        servingSizeLabel: (json['servingSizeLabel'] as num?)?.toDouble() ?? 100,
        servingUnit: json['servingUnit'] as String? ?? 'g',
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
        sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
        barcode: json['barcode'] as String? ?? '',
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}
