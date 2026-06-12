import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/macro_bar.dart';
import '../widgets/water_card.dart';
import '../widgets/weight_trend_card.dart';
import '../widgets/meal_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${state.profile?.name.isNotEmpty == true ? state.profile!.name : 'there'}!',
              style: AppTextStyles.titleLarge,
            ),
            Text(
              _greeting(),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
            ),
          ],
        ),
        actions: [
          if (state.streakDays > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, color: AppColors.accentOrange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${state.streakDays}',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentOrange, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(),
                )
              else ...[
                CalorieRing(
                  consumed: state.consumedCalories,
                  goal: state.profile?.dailyCalorieGoal ?? 2000,
                  remaining: state.remainingCalories,
                ),
                const SizedBox(height: 16),
                MacroBar(
                  protein: state.todayLog?.totalProtein ?? 0,
                  proteinGoal: state.macros['proteinG'] ?? 0,
                  carbs: state.todayLog?.totalCarbs ?? 0,
                  carbsGoal: state.macros['carbsG'] ?? 0,
                  fat: state.todayLog?.totalFat ?? 0,
                  fatGoal: state.macros['fatG'] ?? 0,
                ),
                const SizedBox(height: 14),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: WaterCard(
                        current: state.todayLog?.totalWaterMl ?? 0,
                        goal: 2000,
                        onAdd: () => ref.read(dashboardProvider.notifier).addWaterEntry(250),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: WeightTrendCard(
                        currentWeight: state.latestWeight?.weightKg,
                        goalWeight: state.profile?.targetWeightKg,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                MealSummaryCard(
                  foodEntries: state.todayLog?.foodEntries ?? [],
                  onDelete: (id) => ref.read(dashboardProvider.notifier).deleteFoodEntry(id),
                ),
                const SizedBox(height: 100),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}
