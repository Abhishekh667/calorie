import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryDark = Color(0xFF27AE60);
  static const Color primaryLight = Color(0xFFA8E6CF);

  static const Color accentBlue = Color(0xFF3498DB);
  static const Color accentOrange = Color(0xFFF39C12);
  static const Color accentRed = Color(0xFFE74C3C);
  static const Color accentPurple = Color(0xFF9B59B6);

  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1D1A);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE5E7EB);

  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color textPrimaryDark = Color(0xFFF0F6FC);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color cardDark = Color(0xFF1C2128);
  static const Color dividerDark = Color(0xFF30363D);

  static const Color waterBlue = Color(0xFF4FC3F7);
  static const Color weightPurple = Color(0xFF9575CD);
  static const Color calorieRed = Color(0xFFFF6B6B);
  static const Color calorieGreen = Color(0xFF51CF66);
  static const Color macroProtein = Color(0xFFE74C3C);
  static const Color macroCarbs = Color(0xFFF39C12);
  static const Color macroFat = Color(0xFF3498DB);

  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? backgroundLight : backgroundDark;
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? surfaceLight : surfaceDark;
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? textPrimaryLight : textPrimaryDark;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? textSecondaryLight : textSecondaryDark;
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? cardLight : cardDark;
  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? dividerLight : dividerDark;
}
