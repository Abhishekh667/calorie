import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/food_entry.dart';
import '../models/water_entry.dart';
import '../models/weight_entry.dart';

class DatabaseService {
  static DatabaseService? _instance;
  factory DatabaseService() => _instance ??= DatabaseService._();
  DatabaseService._();

  static const String _userKey = 'user_profile';
  static const String _foodEntriesKey = 'food_entries_';
  static const String _waterEntriesKey = 'water_entries_';
  static const String _weightEntriesKey = 'weight_entries';
  static const String _themeKey = 'theme_mode';
  static const String _remindersKey = 'reminders_enabled';
  static const String _unitsKey = 'use_imperial';

  SharedPreferences? _prefs;

  Future<void> init() async {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
    });
  }

  SharedPreferences get _p {
    if (_prefs == null) {
      throw Exception('DatabaseService not initialized');
    }
    return _prefs!;
  }

  Future<void> ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // User Profile
  Future<void> saveUserProfile(UserProfile profile) async {
    await ensureInitialized();
    await _p.setString(_userKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getUserProfile() async {
    await ensureInitialized();
    final data = _p.getString(_userKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  // Theme Mode
  Future<void> setThemeMode(String mode) async {
    await ensureInitialized();
    await _p.setString(_themeKey, mode);
  }

  Future<String> getThemeMode() async {
    await ensureInitialized();
    return _p.getString(_themeKey) ?? 'system';
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    await ensureInitialized();
    await _p.setBool(_remindersKey, enabled);
  }

  Future<bool> getRemindersEnabled() async {
    await ensureInitialized();
    return _p.getBool(_remindersKey) ?? true;
  }

  Future<void> setUseImperial(bool imperial) async {
    await ensureInitialized();
    await _p.setBool(_unitsKey, imperial);
  }

  Future<bool> getUseImperial() async {
    await ensureInitialized();
    return _p.getBool(_unitsKey) ?? false;
  }

  // Food Entries
  Future<void> saveFoodEntry(FoodEntry entry) async {
    await ensureInitialized();
    final key = _foodEntriesKey + _todayKey();
    final entries = await getFoodEntriesForDate(DateTime.now());
    entries.add(entry);
    final json = entries.map((e) => e.toJson()).toList();
    await _p.setString(key, jsonEncode(json));
  }

  Future<List<FoodEntry>> getFoodEntriesForDate(DateTime date) async {
    await ensureInitialized();
    final key = _foodEntriesKey + _dateKey(date);
    final data = _p.getString(key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => FoodEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteFoodEntry(String entryId) async {
    await ensureInitialized();
    final key = _foodEntriesKey + _todayKey();
    final entries = await getFoodEntriesForDate(DateTime.now());
    entries.removeWhere((e) => e.id == entryId);
    final json = entries.map((e) => e.toJson()).toList();
    await _p.setString(key, jsonEncode(json));
  }

  Future<void> updateFoodEntry(FoodEntry updatedEntry) async {
    await ensureInitialized();
    final key = _foodEntriesKey + _dateKey(updatedEntry.date);
    final entries = await getFoodEntriesForDate(updatedEntry.date);
    final index = entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      entries[index] = updatedEntry;
      final json = entries.map((e) => e.toJson()).toList();
      await _p.setString(key, jsonEncode(json));
    }
  }

  Future<List<FoodEntry>> getFoodEntriesForDateRange(
      DateTime start, DateTime end) async {
    final entries = <FoodEntry>[];
    var current = start;
    while (current.isBefore(end) || current.isSameDate(end)) {
      entries.addAll(await getFoodEntriesForDate(current));
      current = current.add(const Duration(days: 1));
    }
    return entries;
  }

  // Water Entries
  Future<void> saveWaterEntry(WaterEntry entry) async {
    await ensureInitialized();
    final key = _waterEntriesKey + _todayKey();
    final entries = await getWaterEntriesForDate(DateTime.now());
    entries.add(entry);
    final json = entries.map((e) => e.toJson()).toList();
    await _p.setString(key, jsonEncode(json));
  }

  Future<List<WaterEntry>> getWaterEntriesForDate(DateTime date) async {
    await ensureInitialized();
    final key = _waterEntriesKey + _dateKey(date);
    final data = _p.getString(key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => WaterEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Weight Entries
  Future<void> saveWeightEntry(WeightEntry entry) async {
    await ensureInitialized();
    final entries = await getAllWeightEntries();
    entries.add(entry);
    entries.sort((a, b) => a.date.compareTo(b.date));
    final json = entries.map((e) => e.toJson()).toList();
    await _p.setString(_weightEntriesKey, jsonEncode(json));
  }

  Future<List<WeightEntry>> getAllWeightEntries() async {
    await ensureInitialized();
    final data = _p.getString(_weightEntriesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => WeightEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WeightEntry?> getLatestWeight() async {
    final entries = await getAllWeightEntries();
    if (entries.isEmpty) return null;
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries.first;
  }

  // All data
  Future<void> clearAll() async {
    await ensureInitialized();
    await _p.clear();
  }
}

extension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
