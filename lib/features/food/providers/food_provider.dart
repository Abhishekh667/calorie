import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/food_entry.dart';
import '../../../core/models/food_item.dart';
import '../../../core/services/food_database.dart';
import '../../../core/providers/database_provider.dart';

class FoodSearchState {
  final List<FoodItem> results;
  final String query;
  final bool isLoading;

  FoodSearchState({
    this.results = const [],
    this.query = '',
    this.isLoading = false,
  });

  FoodSearchState copyWith({
    List<FoodItem>? results,
    String? query,
    bool? isLoading,
  }) {
    return FoodSearchState(
      results: results ?? this.results,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FoodSearchNotifier extends StateNotifier<FoodSearchState> {
  FoodSearchNotifier() : super(FoodSearchState());

  void search(String query) {
    state = state.copyWith(query: query, isLoading: true);
    final results = FoodDatabase.searchFoods(query);
    state = state.copyWith(results: results, isLoading: false);
  }

  void clearSearch() {
    state = FoodSearchState();
  }
}

final foodSearchProvider =
    StateNotifierProvider<FoodSearchNotifier, FoodSearchState>((ref) {
  return FoodSearchNotifier();
});

class DateFoodState {
  final List<FoodEntry> entries;
  final bool isLoading;

  DateFoodState({
    this.entries = const [],
    this.isLoading = false,
  });

  DateFoodState copyWith({
    List<FoodEntry>? entries,
    bool? isLoading,
  }) {
    return DateFoodState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DateFoodNotifier extends StateNotifier<DateFoodState> {
  final DatabaseService _db;

  DateFoodNotifier(this._db) : super(DateFoodState());

  Future<void> loadEntries(DateTime date) async {
    state = state.copyWith(isLoading: true);
    final entries = await _db.getFoodEntriesForDate(date);
    state = DateFoodState(entries: entries);
  }

  Future<void> addEntry(FoodEntry entry) async {
    await _db.saveFoodEntry(entry);
    await loadEntries(entry.date);
  }

  Future<void> deleteEntry(String id, DateTime date) async {
    await _db.deleteFoodEntry(id);
    await loadEntries(date);
  }
}

final dateFoodProvider =
    StateNotifierProvider<DateFoodNotifier, DateFoodState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return DateFoodNotifier(db);
});

FoodEntry foodEntryFromFoodItem(FoodItem food, String mealType) {
  return FoodEntry(
    id: food.id,
    foodItemId: food.id,
    mealType: mealType,
    date: DateTime.now(),
    servings: food.servingSizeG,
    foodItem: food,
  );
}
