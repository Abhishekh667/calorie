import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/water_provider.dart';

class WaterScreen extends ConsumerStatefulWidget {
  const WaterScreen({super.key});

  @override
  ConsumerState<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends ConsumerState<WaterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(waterProvider.notifier).loadToday());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(waterProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Water Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWaterProgress(state),
          const SizedBox(height: 20),
          _buildQuickAddButtons(),
          const SizedBox(height: 20),
          _buildTodayLog(state),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWaterProgress(WaterState state) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.waterBlue.withValues(alpha: 0.08), AppColors.waterBlue.withValues(alpha: 0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.waterBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.waterBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water_drop_rounded, color: AppColors.waterBlue, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Daily Hydration', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160, height: 160,
                child: CircularProgressIndicator(
                  value: state.progress,
                  strokeWidth: 14,
                  backgroundColor: AppColors.divider(context),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.waterBlue),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(state.totalMl / 1000).toStringAsFixed(1)}L',
                    style: AppTextStyles.numberMedium.copyWith(color: AppColors.waterBlue),
                  ),
                  Text(
                    'of ${(state.goalMl / 1000).toStringAsFixed(0)}L',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.waterBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(state.progress * 100).round()}% of daily goal',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.waterBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.waterBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded, size: 16, color: AppColors.waterBlue),
            ),
            const SizedBox(width: 10),
            Text('Quick Add', style: AppTextStyles.titleSmall),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _WaterButton(ml: 100, label: '100ml', icon: Icons.water_drop_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _WaterButton(ml: 200, label: '200ml', icon: Icons.water_drop_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _WaterButton(ml: 250, label: 'Glass', icon: Icons.local_drink_rounded)),
            const SizedBox(width: 8),
            Expanded(child: _WaterButton(ml: 500, label: 'Bottle', icon: Icons.water_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayLog(WaterState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.waterBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history_rounded, size: 16, color: AppColors.waterBlue),
            ),
            const SizedBox(width: 10),
            Text('Today\'s Log', style: AppTextStyles.titleSmall),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${state.todayEntries.length} entries',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary(context)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.todayEntries.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary(context).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.water_drop_rounded, size: 32, color: AppColors.textSecondary(context).withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text('No water logged today', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context))),
                ],
              ),
            ),
          )
        else
          ...state.todayEntries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.waterBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.water_drop_rounded, color: AppColors.waterBlue, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.amountMl.round()}ml', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                      Text(
                        '${entry.createdAt.hour}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.waterBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(state.goalMl > 0 ? (entry.amountMl / state.goalMl * 100).round() : 0)}%',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.waterBlue, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )),
      ],
    );
  }
}

class _WaterButton extends ConsumerWidget {
  final double ml;
  final String label;
  final IconData icon;

  const _WaterButton({
    required this.ml,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(waterProvider.notifier).addWater(ml),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.waterBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.waterBlue.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.waterBlue, size: 22),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.waterBlue, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
