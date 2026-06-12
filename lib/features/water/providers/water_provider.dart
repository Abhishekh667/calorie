import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/water_entry.dart';
import '../../../core/providers/database_provider.dart';

class WaterState {
  final List<WaterEntry> todayEntries;
  final double totalMl;
  final double goalMl;
  final bool isLoading;

  WaterState({
    this.todayEntries = const [],
    this.totalMl = 0,
    this.goalMl = 2000,
    this.isLoading = false,
  });

  WaterState copyWith({
    List<WaterEntry>? todayEntries,
    double? totalMl,
    double? goalMl,
    bool? isLoading,
  }) {
    return WaterState(
      todayEntries: todayEntries ?? this.todayEntries,
      totalMl: totalMl ?? this.totalMl,
      goalMl: goalMl ?? this.goalMl,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  double get progress => goalMl > 0 ? (totalMl / goalMl).clamp(0, 1) : 0;
  int get glasses => (totalMl / 250).round();
}

class WaterNotifier extends StateNotifier<WaterState> {
  final DatabaseService _db;

  WaterNotifier(this._db) : super(WaterState());

  Future<void> loadToday() async {
    state = state.copyWith(isLoading: true);
    final entries = await _db.getWaterEntriesForDate(DateTime.now());
    final total = entries.fold<double>(0, (s, e) => s + e.amountMl);
    state = WaterState(todayEntries: entries, totalMl: total);
  }

  Future<void> addWater(double ml) async {
    final entry = WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amountMl: ml,
    );
    await _db.saveWaterEntry(entry);
    await loadToday();
  }

  void setGoal(double ml) {
    state = state.copyWith(goalMl: ml);
  }
}

final waterProvider = StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return WaterNotifier(db);
});
