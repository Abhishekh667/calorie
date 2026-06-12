import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class WaterCard extends StatelessWidget {
  final double current;
  final double goal;
  final VoidCallback onAdd;

  const WaterCard({
    super.key,
    required this.current,
    required this.goal,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

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
                  color: AppColors.waterBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.water_drop_rounded, color: AppColors.waterBlue, size: 16),
              ),
              const SizedBox(width: 8),
              Text('Water', style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 5,
                  backgroundColor: AppColors.divider(context),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.waterBlue),
                ),
              ),
              Icon(Icons.water_drop_rounded, color: AppColors.waterBlue.withValues(alpha: 0.8), size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${(current / 1000).toStringAsFixed(1)}L',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            '/ ${(goal / 1000).toStringAsFixed(0)}L',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.waterBlue,
                side: BorderSide(color: AppColors.waterBlue.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text('+ 250ml', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
