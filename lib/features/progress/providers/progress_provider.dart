import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/daily_log.dart';
import '../../../core/providers/database_provider.dart';

class ProgressState {
  final List<DailyLog> weeklyLogs;
  final int streakDays;
  final int totalDaysTracked;
  final bool isLoading;

  ProgressState({
    this.weeklyLogs = const [],
    this.streakDays = 0,
    this.totalDaysTracked = 0,
    this.isLoading = true,
  });

  ProgressState copyWith({
    List<DailyLog>? weeklyLogs,
    int? streakDays,
    int? totalDaysTracked,
    bool? isLoading,
  }) {
    return ProgressState(
      weeklyLogs: weeklyLogs ?? this.weeklyLogs,
      streakDays: streakDays ?? this.streakDays,
      totalDaysTracked: totalDaysTracked ?? this.totalDaysTracked,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  final DatabaseService _db;

  ProgressNotifier(this._db) : super(ProgressState());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final now = DateTime.now();
      final weeklyLogs = <DailyLog>[];
      int totalDays = 0;
      int streak = 0;

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final entries = await _db.getFoodEntriesForDate(date);
        final water = await _db.getWaterEntriesForDate(date);
        final log = DailyLog(date: date, foodEntries: entries, waterEntries: water);
        weeklyLogs.add(log);
        if (entries.isNotEmpty) totalDays++;
      }

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

      state = ProgressState(
        weeklyLogs: weeklyLogs,
        streakDays: streak,
        totalDaysTracked: totalDays,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ProgressNotifier(db);
});
