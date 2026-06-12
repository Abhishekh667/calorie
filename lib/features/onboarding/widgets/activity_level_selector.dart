import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ActivityLevelSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const ActivityLevelSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _ActivityOption(
              optionKey: 'sedentary',
              icon: Icons.weekend_rounded,
              title: 'Sedentary',
              subtitle: 'Desk job, little exercise',
              isSelected: selected == 'sedentary',
              onTap: () => onSelect('sedentary'),
            ),
            const SizedBox(height: 8),
            _ActivityOption(
              optionKey: 'light',
              icon: Icons.directions_walk_rounded,
              title: 'Lightly Active',
              subtitle: '1-2 days/week light exercise',
              isSelected: selected == 'light',
              onTap: () => onSelect('light'),
            ),
            const SizedBox(height: 8),
            _ActivityOption(
              optionKey: 'moderate',
              icon: Icons.directions_bike_rounded,
              title: 'Moderately Active',
              subtitle: '3-5 days/week moderate exercise',
              isSelected: selected == 'moderate',
              onTap: () => onSelect('moderate'),
            ),
            const SizedBox(height: 8),
            _ActivityOption(
              optionKey: 'active',
              icon: Icons.fitness_center_rounded,
              title: 'Very Active',
              subtitle: '6-7 days/week intense exercise',
              isSelected: selected == 'active',
              onTap: () => onSelect('active'),
            ),
            const SizedBox(height: 8),
            _ActivityOption(
              optionKey: 'very_active',
              icon: Icons.emoji_people,
              title: 'Extremely Active',
              subtitle: 'Athlete / physical job',
              isSelected: selected == 'very_active',
              onTap: () => onSelect('very_active'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityOption extends StatelessWidget {
  final String optionKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityOption({
    required this.optionKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.background(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary(context), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}
