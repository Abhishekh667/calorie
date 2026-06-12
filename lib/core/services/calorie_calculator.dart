class CalorieCalculator {
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    if (gender == 'male') {
      return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    }
    return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
  }

  static double getActivityMultiplier(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      default:
        return 1.55;
    }
  }

  static double getGoalAdjustment(String goal) {
    switch (goal) {
      case 'lose':
        return -500;
      case 'gain':
        return 500;
      case 'maintain':
      default:
        return 0;
    }
  }

  static double calculateDailyCalorieGoal({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    final tdee = bmr * getActivityMultiplier(activityLevel);
    final adjustment = getGoalAdjustment(goal);
    return (tdee + adjustment).roundToDouble();
  }

  static String getActivityLevelLabel(String key) {
    switch (key) {
      case 'sedentary':
        return 'Sedentary';
      case 'light':
        return 'Lightly Active';
      case 'moderate':
        return 'Moderately Active';
      case 'active':
        return 'Very Active';
      case 'very_active':
        return 'Extremely Active';
      default:
        return key;
    }
  }

  static String getGoalLabel(String key) {
    switch (key) {
      case 'lose':
        return 'Lose Weight';
      case 'maintain':
        return 'Maintain Weight';
      case 'gain':
        return 'Gain Weight';
      default:
        return key;
    }
  }

  static Map<String, double> getMacroSplit({
    required double calories,
    required String goal,
  }) {
    double proteinRatio, carbRatio, fatRatio;
    switch (goal) {
      case 'lose':
        proteinRatio = 0.40;
        carbRatio = 0.30;
        fatRatio = 0.30;
        break;
      case 'gain':
        proteinRatio = 0.30;
        carbRatio = 0.45;
        fatRatio = 0.25;
        break;
      case 'maintain':
      default:
        proteinRatio = 0.30;
        carbRatio = 0.40;
        fatRatio = 0.30;
        break;
    }
    return {
      'proteinG': ((calories * proteinRatio) / 4).roundToDouble(),
      'carbsG': ((calories * carbRatio) / 4).roundToDouble(),
      'fatG': ((calories * fatRatio) / 9).roundToDouble(),
      'proteinCal': (calories * proteinRatio).roundToDouble(),
      'carbsCal': (calories * carbRatio).roundToDouble(),
      'fatCal': (calories * fatRatio).roundToDouble(),
    };
  }
}
