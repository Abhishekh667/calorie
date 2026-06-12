import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WeightTrendCard extends StatelessWidget {
  final double? currentWeight;
  final double? goalWeight;

  const WeightTrendCard({
    super.key,
    this.currentWeight,
    this.goalWeight,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = currentWeight != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.weightPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.monitor_weight_rounded, color: AppColors.weightPurple, size: 16),
              ),
              const SizedBox(width: 8),
              Text('Weight', style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: hasData
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${currentWeight!.toStringAsFixed(1)}',
                          style: AppTextStyles.numberSmall.copyWith(
                            color: AppColors.weightPurple,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          'kg',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monitor_weight_outlined, color: AppColors.textSecondary(context).withValues(alpha: 0.35), size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'No data',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary(context).withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Log your weight to see progress',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary(context).withValues(alpha: 0.45)),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          if (goalWeight != null && hasData) ...[
            Center(
              child: Text(
                'Goal: ${goalWeight!.toStringAsFixed(1)} kg',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (currentWeight! / goalWeight!).clamp(0, 1),
                backgroundColor: AppColors.divider(context),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.weightPurple),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
