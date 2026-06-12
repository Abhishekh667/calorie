import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/weight_provider.dart';

class WeightScreen extends ConsumerStatefulWidget {
  const WeightScreen({super.key});

  @override
  ConsumerState<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends ConsumerState<WeightScreen> {
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(weightProvider.notifier).loadEntries());
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weightProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Weight Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddWeight(),
          const SizedBox(height: 16),
          _buildPeriodSelector(state),
          const SizedBox(height: 16),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _buildChart(state),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAddWeight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.weightPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.monitor_weight_rounded, color: AppColors.weightPurple, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter weight',
                suffixText: 'kg',
                filled: true,
                fillColor: AppColors.background(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () {
              final weight = double.tryParse(_weightController.text);
              if (weight != null && weight > 0) {
                ref.read(weightProvider.notifier).addEntry(weight);
                _weightController.clear();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.weightPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text('Log'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(WeightState state) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.weightPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.date_range_rounded, size: 16, color: AppColors.weightPurple),
        ),
        const SizedBox(width: 10),
        Text('Period', style: AppTextStyles.titleSmall),
        const Spacer(),
        _PeriodChip(
          label: 'Week',
          selected: state.selectedPeriod == 'week',
          onTap: () => ref.read(weightProvider.notifier).setPeriod('week'),
        ),
        const SizedBox(width: 8),
        _PeriodChip(
          label: 'Month',
          selected: state.selectedPeriod == 'month',
          onTap: () => ref.read(weightProvider.notifier).setPeriod('month'),
        ),
      ],
    );
  }

  Widget _buildChart(WeightState state) {
    if (state.entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary(context).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.weightPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.monitor_weight_rounded, size: 36, color: AppColors.weightPurple),
              ),
              const SizedBox(height: 16),
              Text('No weight data yet', style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text('Log your first weight above', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final cutoff = state.selectedPeriod == 'week'
        ? now.subtract(const Duration(days: 7))
        : now.subtract(const Duration(days: 30));

    final filtered = state.entries
        .where((e) => e.date.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (filtered.isEmpty) {
      return const Center(child: Text('No data for this period'));
    }

    final minY = filtered.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b) - 1;
    final maxY = filtered.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b) + 1;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary(context).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          height: 280,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (filtered.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.divider(context),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.round()}',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context)),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.round();
                      if (idx < 0 || idx >= filtered.length) return const SizedBox();
                      return Text(
                        '${filtered[idx].date.day}/${filtered[idx].date.month}',
                        style: TextStyle(fontSize: 9, color: AppColors.textSecondary(context)),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: filtered.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weightKg)).toList(),
                  isCurved: true,
                  color: AppColors.weightPurple,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.weightPurple,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.weightPurple.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
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
                child: _WeightStat(
                  label: 'Current',
                  value: '${filtered.last.weightKg.toStringAsFixed(1)} kg',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
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
                child: _WeightStat(
                  label: 'Start',
                  value: '${filtered.first.weightKg.toStringAsFixed(1)} kg',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
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
                child: _WeightStat(
                  label: 'Change',
                  value: '${(filtered.last.weightKg - filtered.first.weightKg).toStringAsFixed(1)} kg',
                  color: filtered.last.weightKg < filtered.first.weightKg
                      ? AppColors.success
                      : AppColors.calorieRed,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.weightPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.weightPurple : AppColors.divider(context),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _WeightStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _WeightStat({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
