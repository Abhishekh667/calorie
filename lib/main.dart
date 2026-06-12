import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/database/database_service.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseService();
  await db.ensureInitialized();

  final profile = await db.getUserProfile();
  final startRoute = profile?.onboardingCompleted == true;

  runApp(
    ProviderScope(
      child: CalorieFlowApp(startWithOnboarding: !startRoute),
    ),
  );
}

class CalorieFlowApp extends ConsumerWidget {
  final bool startWithOnboarding;

  const CalorieFlowApp({
    super.key,
    this.startWithOnboarding = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Calorie Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      home: startWithOnboarding
          ? const OnboardingScreen()
          : const HomeShell(),
    );
  }
}
