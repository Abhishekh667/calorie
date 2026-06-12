import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/calorie_calculator.dart';

class OnboardingState {
  final int currentPage;
  final String goal;
  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double targetWeightKg;
  final String activityLevel;
  final bool isComplete;

  OnboardingState({
    this.currentPage = 0,
    this.goal = 'maintain',
    this.name = '',
    this.age = 25,
    this.gender = 'male',
    this.heightCm = 170,
    this.weightKg = 70,
    this.targetWeightKg = 70,
    this.activityLevel = 'moderate',
    this.isComplete = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    String? goal,
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    String? activityLevel,
    bool? isComplete,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      goal: goal ?? this.goal,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  UserProfile buildProfile() {
    final dailyCalories = CalorieCalculator.calculateDailyCalorieGoal(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
    );
    return UserProfile(
      id: const Uuid().v4(),
      name: name,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      targetWeightKg: targetWeightKg,
      activityLevel: activityLevel,
      goal: goal,
      dailyCalorieGoal: dailyCalories,
      onboardingCompleted: true,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

  void nextPage() {
    if (state.currentPage < 4) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setGoal(String goal) {
    state = state.copyWith(goal: goal);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setAge(int age) {
    state = state.copyWith(age: age);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void setHeight(double height) {
    state = state.copyWith(heightCm: height);
  }

  void setWeight(double weight) {
    state = state.copyWith(weightKg: weight);
  }

  void setTargetWeight(double weight) {
    state = state.copyWith(targetWeightKg: weight);
  }

  void setActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }

  void completeOnboarding() {
    state = state.copyWith(isComplete: true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
