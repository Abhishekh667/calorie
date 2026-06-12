import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/daily_log.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/food_entry.dart';
import '../../../core/models/water_entry.dart';
import '../../../core/models/weight_entry.dart';
import '../../../core/services/calorie_calculator.dart';
import '../../../core/providers/database_provider.dart';

class DashboardState {
  final DailyLog? todayLog;
  final UserProfile? profile;
  final WeightEntry? latestWeight;
  final int streakDays;
  final bool isLoading;

  DashboardState({
    this.todayLog,
    this.profile,
    this.latestWeight,
    this.streakDays = 0,
    this.isLoading = false,
  });

  DashboardState copyWith({
    DailyLog? todayLog,
    UserProfile? profile,
    WeightEntry? latestWeight,
    int? streakDays,
    bool? isLoading,
  }) {
    return DashboardState(
      todayLog: todayLog ?? this.todayLog,
      profile: profile ?? this.profile,
      latestWeight: latestWeight ?? this.latestWeight,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, double> get macros {
    if (profile == null) return {'proteinG': 0, 'carbsG': 0, 'fatG': 0};
    return CalorieCalculator.getMacroSplit(
      calories: profile!.dailyCalorieGoal,
      goal: profile!.goal,
    );
  }

  double get consumedCalories => todayLog?.totalCalories ?? 0;
  double get remainingCalories {
    if (profile == null) return 0;
    return profile!.dailyCalorieGoal - consumedCalories;
  }
  double get proteinProgress {
    if (todayLog == null) return 0;
    final target = macros['proteinG'] ?? 1;
    return (todayLog!.totalProtein / target).clamp(0, 1);
  }
  double get carbsProgress {
    if (todayLog == null) return 0;
    final target = macros['carbsG'] ?? 1;
    return (todayLog!.totalCarbs / target).clamp(0, 1);
  }
  double get fatProgress {
    if (todayLog == null) return 0;
    final target = macros['fatG'] ?? 1;
    return (todayLog!.totalFat / target).clamp(0, 1);
  }
  double get waterProgress {
    if (todayLog == null) return 0;
    const target = 2000.0;
    return (todayLog!.totalWaterMl / target).clamp(0, 1);
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DatabaseService _db;

  DashboardNotifier(this._db) : super(DashboardState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _db.getUserProfile();
      final now = DateTime.now();
      final entries = await _db.getFoodEntriesForDate(now);
      final water = await _db.getWaterEntriesForDate(now);
      final weight = await _db.getLatestWeight();

      int streak = 0;
      var check = now.subtract(const Duration(days: 1));
      for (int i = 0; i < 365; i++) {
        final dayEntries = await _db.getFoodEntriesForDate(check);
        if (dayEntries.isNotEmpty) {
          streak++;
          check = check.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      state = DashboardState(
        todayLog: DailyLog(
          date: now,
          foodEntries: entries,
          waterEntries: water,
          weightEntry: weight,
        ),
        profile: profile,
        latestWeight: weight,
        streakDays: streak,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addFoodEntry(FoodEntry entry) async {
    await _db.saveFoodEntry(entry);
    await loadData();
  }

  Future<void> deleteFoodEntry(String entryId) async {
    await _db.deleteFoodEntry(entryId);
    await loadData();
  }

  Future<void> addWaterEntry(double amountMl) async {
    final entry = WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amountMl: amountMl,
    );
    await _db.saveWaterEntry(entry);
    await loadData();
  }

  Future<void> addWeightEntry(double weightKg) async {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weightKg: weightKg,
    );
    await _db.saveWeightEntry(entry);
    await loadData();
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return DashboardNotifier(db);
});
