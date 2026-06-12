import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/daily_log.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/weight_entry.dart';
import '../../../core/providers/database_provider.dart';

class InsightsData {
  final List<DailyLog> currentWeekLogs;
  final List<DailyLog> previousWeekLogs;
  final List<WeightEntry> weightHistory;
  final UserProfile? profile;
  final int streakDays;
  final bool isLoading;
  final String? error;

  InsightsData({
    this.currentWeekLogs = const [],
    this.previousWeekLogs = const [],
    this.weightHistory = const [],
    this.profile,
    this.streakDays = 0,
    this.isLoading = true,
    this.error,
  });

  InsightsData copyWith({
    List<DailyLog>? currentWeekLogs,
    List<DailyLog>? previousWeekLogs,
    List<WeightEntry>? weightHistory,
    UserProfile? profile,
    int? streakDays,
    bool? isLoading,
    String? error,
  }) {
    return InsightsData(
      currentWeekLogs: currentWeekLogs ?? this.currentWeekLogs,
      previousWeekLogs: previousWeekLogs ?? this.previousWeekLogs,
      weightHistory: weightHistory ?? this.weightHistory,
      profile: profile ?? this.profile,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  double get avgCalories {
    if (currentWeekLogs.isEmpty) return 0;
    return currentWeekLogs.fold<double>(0, (s, l) => s + l.totalCalories) / currentWeekLogs.length;
  }

  double get prevAvgCalories {
    if (previousWeekLogs.isEmpty) return 0;
    return previousWeekLogs.fold<double>(0, (s, l) => s + l.totalCalories) / previousWeekLogs.length;
  }

  double get avgProtein {
    if (currentWeekLogs.isEmpty) return 0;
    return currentWeekLogs.fold<double>(0, (s, l) => s + l.totalProtein) / currentWeekLogs.length;
  }

  double get avgCarbs {
    if (currentWeekLogs.isEmpty) return 0;
    return currentWeekLogs.fold<double>(0, (s, l) => s + l.totalCarbs) / currentWeekLogs.length;
  }

  double get avgFat {
    if (currentWeekLogs.isEmpty) return 0;
    return currentWeekLogs.fold<double>(0, (s, l) => s + l.totalFat) / currentWeekLogs.length;
  }

  double get avgWater {
    if (currentWeekLogs.isEmpty) return 0;
    return currentWeekLogs.fold<double>(0, (s, l) => s + l.totalWaterMl) / currentWeekLogs.length;
  }

  int get daysTracked => currentWeekLogs.where((l) => l.totalCalories > 0).length;

  double get weightChange {
    if (weightHistory.length < 2) return 0;
    return weightHistory.last.weightKg - weightHistory.first.weightKg;
  }
}

class InsightsNotifier extends StateNotifier<InsightsData> {
  final DatabaseService _db;

  InsightsNotifier(this._db) : super(InsightsData());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final profile = await _db.getUserProfile();

      final currentWeek = <DailyLog>[];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final entries = await _db.getFoodEntriesForDate(date);
        final water = await _db.getWaterEntriesForDate(date);
        currentWeek.add(DailyLog(date: date, foodEntries: entries, waterEntries: water));
      }

      final previousWeek = <DailyLog>[];
      for (int i = 13; i >= 7; i--) {
        final date = now.subtract(Duration(days: i));
        final entries = await _db.getFoodEntriesForDate(date);
        final water = await _db.getWaterEntriesForDate(date);
        previousWeek.add(DailyLog(date: date, foodEntries: entries, waterEntries: water));
      }

      final weightHistory = await _db.getAllWeightEntries();

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

      state = InsightsData(
        currentWeekLogs: currentWeek,
        previousWeekLogs: previousWeek,
        weightHistory: weightHistory,
        profile: profile,
        streakDays: streak,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final insightsProvider = StateNotifierProvider<InsightsNotifier, InsightsData>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return InsightsNotifier(db);
});
