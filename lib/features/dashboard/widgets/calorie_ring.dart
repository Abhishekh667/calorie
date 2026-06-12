import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double goal;
  final double remaining;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (consumed / goal).clamp(0.0, 1.0);
    final color = remaining >= 0 ? AppColors.primary : AppColors.calorieRed;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_fire_department, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calorie Budget', style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${consumed.round()} / ${goal.round()} cal',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${remaining >= 0 ? '' : '+'}${remaining.round()} left',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CircularPercentIndicator(
            radius: 82,
            lineWidth: 12,
            percent: percent,
            progressColor: color,
            backgroundColor: AppColors.divider(context),
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${consumed.round()}',
                  style: AppTextStyles.numberMedium.copyWith(color: AppColors.textPrimary(context)),
                ),
                Text(
                  'of ${goal.round()}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
