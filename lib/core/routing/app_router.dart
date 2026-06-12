import 'package:flutter/material.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/food/screens/food_diary_screen.dart';
import '../../features/water/screens/water_screen.dart';
import '../../features/weight/screens/weight_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/premium/screens/premium_screen.dart';
import '../../features/ask_me/screens/ask_me_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String foodDiary = '/food-diary';
  static const String water = '/water';
  static const String weight = '/weight';
  static const String progress = '/progress';
  static const String settings = '/settings';
  static const String premium = '/premium';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case foodDiary:
        return MaterialPageRoute(builder: (_) => const FoodDiaryScreen());
      case water:
        return MaterialPageRoute(builder: (_) => const WaterScreen());
      case weight:
        return MaterialPageRoute(builder: (_) => const WeightScreen());
      case progress:
        return MaterialPageRoute(builder: (_) => const ProgressScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case premium:
        return MaterialPageRoute(builder: (_) => const PremiumScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeShell());
    }
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final _pages = const [
    DashboardScreen(),
    FoodDiaryScreen(),
    AskMeScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            activeIcon: Icon(Icons.restaurant_rounded),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Ask Me',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddFoodScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Food'),
            )
          : null,
    );
  }
}
