import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/food_entry.dart';

class MealSummaryCard extends StatelessWidget {
  final List<FoodEntry> foodEntries;
  final Function(String id) onDelete;

  const MealSummaryCard({
    super.key,
    required this.foodEntries,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final meals = <String, List<FoodEntry>>{};
    for (final e in foodEntries) {
      meals.putIfAbsent(e.mealType, () => []);
      meals[e.mealType]!.add(e);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text('Today\'s Meals', style: AppTextStyles.titleSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${foodEntries.length} items',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (foodEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.restaurant_rounded, size: 32, color: AppColors.textSecondary(context).withValues(alpha: 0.4)),
                    const SizedBox(height: 8),
                    Text(
                      'No meals logged yet today',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (meals.containsKey('breakfast'))
              _MealSection(
                title: 'Breakfast',
                icon: Icons.wb_sunny_rounded,
                entries: meals['breakfast']!,
                onDelete: onDelete,
              ),
            if (meals.containsKey('lunch'))
              _MealSection(
                title: 'Lunch',
                icon: Icons.cloud_rounded,
                entries: meals['lunch']!,
                onDelete: onDelete,
              ),
            if (meals.containsKey('dinner'))
              _MealSection(
                title: 'Dinner',
                icon: Icons.nights_stay_rounded,
                entries: meals['dinner']!,
                onDelete: onDelete,
              ),
            if (meals.containsKey('snack'))
              _MealSection(
                title: 'Snacks',
                icon: Icons.cookie,
                entries: meals['snack']!,
                onDelete: onDelete,
              ),
          ],
          if (foodEntries.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Total: ${foodEntries.fold<double>(0, (sum, e) => sum + e.calories).round()} cal',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FoodEntry> entries;
  final Function(String id) onDelete;

  const _MealSection({
    required this.title,
    required this.icon,
    required this.entries,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalCal = entries.fold<double>(0, (s, e) => s + e.calories);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary(context)),
              const SizedBox(width: 6),
              Text(title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${totalCal.round()} cal', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...entries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restaurant_rounded, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.foodItem.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.servingGram.toStringAsFixed(0)}g  ·  P: ${entry.protein.toStringAsFixed(1)}  C: ${entry.carbs.toStringAsFixed(1)}  F: ${entry.fat.toStringAsFixed(1)}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                Text('${entry.calories.round()}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary(context))),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDelete(context, entry.id),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary(context)),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Meal'),
        content: const Text('Are you sure you want to remove this meal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete(id);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
