import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/calorie_calculator.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/routing/app_router.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/goal_selection_card.dart';
import '../widgets/user_info_form.dart';
import '../widgets/activity_level_selector.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(ref, state),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildPage(ref, state),
              ),
            ),
            _buildBottomBar(state),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(WidgetRef ref, OnboardingState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (state.currentPage > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => ref.read(onboardingProvider.notifier).previousPage(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => ref.read(onboardingProvider.notifier).nextPage(),
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(state),
          const SizedBox(height: 8),
          Text(
            _getTitle(state.currentPage),
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: 4),
          Text(
            _getSubtitle(state.currentPage),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(OnboardingState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: (state.currentPage + 1) / 5,
        backgroundColor: AppColors.divider(context),
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        minHeight: 4,
      ),
    );
  }

  String _getTitle(int page) {
    switch (page) {
      case 0:
        return 'What\'s your goal?';
      case 1:
        return 'Tell us about yourself';
      case 2:
        return 'Your body metrics';
      case 3:
        return 'Activity level';
      case 4:
        return 'Your calorie goal';
      default:
        return '';
    }
  }

  String _getSubtitle(int page) {
    switch (page) {
      case 0:
        return 'We\'ll personalize your plan based on your goal.';
      case 1:
        return 'This helps us calculate your needs accurately.';
      case 2:
        return 'Height, weight, and target weight.';
      case 3:
        return 'How active are you during the day?';
      case 4:
        return 'Based on your info, here\'s your daily target.';
      default:
        return '';
    }
  }

  Widget _buildPage(WidgetRef ref, OnboardingState state) {
    switch (state.currentPage) {
      case 0:
        return GoalSelectionCard(
          selectedGoal: state.goal,
          onSelect: (goal) => ref.read(onboardingProvider.notifier).setGoal(goal),
        );
      case 1:
        return UserInfoForm(
          name: state.name,
          age: state.age,
          gender: state.gender,
          onNameChanged: (v) => ref.read(onboardingProvider.notifier).setName(v),
          onAgeChanged: (v) => ref.read(onboardingProvider.notifier).setAge(v),
          onGenderChanged: (v) => ref.read(onboardingProvider.notifier).setGender(v),
        );
      case 2:
        return _BodyMetricsForm(
          state: state,
          onHeightChanged: (v) => ref.read(onboardingProvider.notifier).setHeight(v),
          onWeightChanged: (v) => ref.read(onboardingProvider.notifier).setWeight(v),
          onTargetWeightChanged: (v) => ref.read(onboardingProvider.notifier).setTargetWeight(v),
        );
      case 3:
        return ActivityLevelSelector(
          selected: state.activityLevel,
          onSelect: (v) => ref.read(onboardingProvider.notifier).setActivityLevel(v),
        );
      case 4:
        return _CalorieGoalPreview(state: state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar(OnboardingState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () async {
              if (state.currentPage == 4) {
                final profile = state.buildProfile();
                final db = ref.read(databaseServiceProvider);
                await db.saveUserProfile(profile);
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeShell()),
                  );
                }
              } else {
                ref.read(onboardingProvider.notifier).nextPage();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              state.currentPage == 4 ? 'Get Started' : 'Continue',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyMetricsForm extends StatelessWidget {
  final OnboardingState state;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<double> onTargetWeightChanged;

  const _BodyMetricsForm({
    required this.state,
    required this.onHeightChanged,
    required this.onWeightChanged,
    required this.onTargetWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _MetricField(
            label: 'Height (cm)',
            value: state.heightCm.round(),
            onChanged: (v) => onHeightChanged(v.toDouble()),
          ),
          const SizedBox(height: 16),
          _MetricField(
            label: 'Current Weight (kg)',
            value: state.weightKg.round(),
            onChanged: (v) => onWeightChanged(v.toDouble()),
          ),
          const SizedBox(height: 16),
          _MetricField(
            label: 'Target Weight (kg)',
            value: state.targetWeightKg.round(),
            onChanged: (v) => onTargetWeightChanged(v.toDouble()),
          ),
        ],
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _MetricField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: AppColors.textSecondary(context),
                onPressed: value > 20 ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.numberMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: AppColors.primary,
                onPressed: value < 300 ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalorieGoalPreview extends StatelessWidget {
  final OnboardingState state;

  const _CalorieGoalPreview({required this.state});

  @override
  Widget build(BuildContext context) {
    final profile = state.buildProfile();
    final macros = CalorieCalculator.getMacroSplit(
      calories: profile.dailyCalorieGoal,
      goal: state.goal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Column(
              children: [
                Text(
                  '${profile.dailyCalorieGoal.round()}',
                  style: AppTextStyles.numberLarge.copyWith(color: AppColors.primary),
                ),
                Text(
                  'calories/day',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroChip(
                label: 'Protein',
                value: '${macros['proteinG']!.round()}g',
                color: AppColors.macroProtein,
              ),
              _MacroChip(
                label: 'Carbs',
                value: '${macros['carbsG']!.round()}g',
                color: AppColors.macroCarbs,
              ),
              _MacroChip(
                label: 'Fat',
                value: '${macros['fatG']!.round()}g',
                color: AppColors.macroFat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.titleMedium),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }
}
