import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class GoalSelectionCard extends StatelessWidget {
  final String selectedGoal;
  final ValueChanged<String> onSelect;

  const GoalSelectionCard({
    super.key,
    required this.selectedGoal,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoalOption(
            icon: Icons.trending_down,
            title: 'Lose Weight',
            subtitle: 'Calorie deficit for fat loss',
            isSelected: selectedGoal == 'lose',
            onTap: () => onSelect('lose'),
            color: AppColors.accentOrange,
          ),
          const SizedBox(height: 12),
          _GoalOption(
            icon: Icons.balance,
            title: 'Maintain Weight',
            subtitle: 'Keep your current weight',
            isSelected: selectedGoal == 'maintain',
            onTap: () => onSelect('maintain'),
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _GoalOption(
            icon: Icons.trending_up,
            title: 'Gain Weight',
            subtitle: 'Calorie surplus for muscle gain',
            isSelected: selectedGoal == 'gain',
            onTap: () => onSelect('gain'),
            color: AppColors.accentBlue,
          ),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _GoalOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 2) : null,
          boxShadow: isSelected ? null : [
            BoxShadow(
              color: AppColors.textPrimary(context).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.15) : AppColors.background(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? color : AppColors.textSecondary(context), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleLarge.copyWith(
                    color: isSelected ? color : null,
                  )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  )),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
