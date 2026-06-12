import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/weight_entry.dart';
import '../../../core/providers/database_provider.dart';

class WeightState {
  final List<WeightEntry> entries;
  final bool isLoading;
  final String selectedPeriod; // 'week' or 'month'

  WeightState({
    this.entries = const [],
    this.isLoading = false,
    this.selectedPeriod = 'week',
  });

  WeightState copyWith({
    List<WeightEntry>? entries,
    bool? isLoading,
    String? selectedPeriod,
  }) {
    return WeightState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

class WeightNotifier extends StateNotifier<WeightState> {
  final DatabaseService _db;

  WeightNotifier(this._db) : super(WeightState());

  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true);
    final entries = await _db.getAllWeightEntries();
    state = WeightState(entries: entries);
  }

  Future<void> addEntry(double weightKg) async {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weightKg: weightKg,
    );
    await _db.saveWeightEntry(entry);
    await loadEntries();
  }

  void setPeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
  }
}

final weightProvider = StateNotifierProvider<WeightNotifier, WeightState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return WeightNotifier(db);
});
