import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../database/database_service.dart';
import 'database_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) {
    final notifier = ThemeModeNotifier(ref);
    notifier.loadSavedTheme();
    return notifier;
  },
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeModeNotifier(this._ref) : super(ThemeMode.light);

  Future<void> loadSavedTheme() async {
    final db = _ref.read(databaseServiceProvider);
    final saved = await db.getThemeMode();
    if (saved == 'dark') {
      state = ThemeMode.dark;
    } else if (saved == 'light') {
      state = ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = next;
    final db = _ref.read(databaseServiceProvider);
    await db.setThemeMode(next == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final db = _ref.read(databaseServiceProvider);
    await db.setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final appThemeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  switch (mode) {
    case ThemeMode.dark:
      return AppTheme.darkTheme;
    case ThemeMode.light:
      return AppTheme.lightTheme;
    default:
      return AppTheme.lightTheme;
  }
});
