import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/database_provider.dart';

class SettingsState {
  final UserProfile? profile;
  final bool isLoading;

  SettingsState({
    this.profile,
    this.isLoading = false,
  });

  SettingsState copyWith({
    UserProfile? profile,
    bool? isLoading,
  }) {
    return SettingsState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final DatabaseService _db;

  SettingsNotifier(this._db) : super(SettingsState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    final profile = await _db.getUserProfile();
    state = SettingsState(profile: profile);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _db.saveUserProfile(profile);
    state = state.copyWith(profile: profile);
  }

  Future<void> updateCalorieGoal(double goal) async {
    if (state.profile == null) return;
    final updated = state.profile!.copyWith(dailyCalorieGoal: goal);
    await updateProfile(updated);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SettingsNotifier(db);
});
