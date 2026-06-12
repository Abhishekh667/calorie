import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/insights_provider.dart';
import '../services/pdf_report_service.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  final _pdfService = PdfReportService();
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(insightsProvider.notifier).loadData());
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Deep Insights'),
        actions: [
          if (!data.isLoading)
            IconButton(
              icon: _isGeneratingPdf
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(Icons.picture_as_pdf_rounded, color: AppColors.textSecondary(context)),
              tooltip: 'Download PDF Report',
              onPressed: _isGeneratingPdf ? null : () => _generatePdf(data),
            ),
        ],
      ),
      body: data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : data.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text('Failed to load insights', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => ref.read(insightsProvider.notifier).loadData(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSummaryGrid(data),
                    const SizedBox(height: 16),
                    _buildCalorieChart(data),
                    const SizedBox(height: 16),
                    _buildMacroCard(data),
                    const SizedBox(height: 16),
                    _buildWaterCard(data),
                    const SizedBox(height: 16),
                    _buildWeightCard(data),
                    const SizedBox(height: 16),
                    _buildComparisonCard(data),
                    const SizedBox(height: 16),
                    _buildDownloadButton(data),
                    const SizedBox(height: 40),
                  ],
                ),
    );
  }

  Widget _buildSummaryGrid(InsightsData data) {
    return Row(
      children: [
        Expanded(child: _StatCard(
          icon: Icons.local_fire_department_rounded,
          label: 'Avg Calories',
          value: '${data.avgCalories.round()}',
          subtitle: 'kcal/day',
          color: AppColors.accentOrange,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          icon: Icons.fitness_center_rounded,
          label: 'Avg Protein',
          value: '${data.avgProtein.round()}',
          subtitle: 'g/day',
          color: AppColors.macroProtein,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          icon: Icons.water_drop_rounded,
          label: 'Avg Water',
          value: '${data.avgWater.round()}',
          subtitle: 'ml/day',
          color: AppColors.waterBlue,
        )),
      ],
    );
  }

  Widget _buildCalorieChart(InsightsData data) {
    final logs = data.currentWeekLogs;
    final maxCal = logs.isEmpty
        ? 1.0
        : logs.map((l) => l.totalCalories).reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.accentOrange),
              ),
              const SizedBox(width: 10),
              Text('Daily Calories', style: AppTextStyles.titleSmall),
              const Spacer(),
              Text('Goal: ${data.profile?.dailyCalorieGoal.round() ?? 2000}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCal * 1.3).clamp(data.profile?.dailyCalorieGoal ?? 2000, double.infinity),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.round()}',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= 7) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            days[idx],
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context), fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxCal / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.divider(context),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: logs.asMap().entries.map((entry) {
                  final cal = entry.value.totalCalories;
                  final goal = data.profile?.dailyCalorieGoal ?? 2000;
                  final color = cal <= goal ? AppColors.primary : AppColors.error;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: cal == 0 ? 0.1 : cal,
                        color: color,
                        width: 18,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(InsightsData data) {
    final p = data.avgProtein;
    final c = data.avgCarbs;
    final f = data.avgFat;
    final total = p + c + f;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.macroProtein.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pie_chart_rounded, size: 16, color: AppColors.macroProtein),
              ),
              const SizedBox(width: 10),
              Text('Macro Distribution', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: total > 0 ? p : 1,
                    color: AppColors.macroProtein,
                    title: '${total > 0 ? (p / total * 100).round() : 0}%',
                    radius: 35,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: total > 0 ? c : 1,
                    color: AppColors.macroCarbs,
                    title: '${total > 0 ? (c / total * 100).round() : 0}%',
                    radius: 35,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: total > 0 ? f : 1,
                    color: AppColors.macroFat,
                    title: '${total > 0 ? (f / total * 100).round() : 0}%',
                    radius: 35,
                    titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(color: AppColors.macroProtein, label: 'Protein', value: '${p.round()}g'),
              _LegendItem(color: AppColors.macroCarbs, label: 'Carbs', value: '${c.round()}g'),
              _LegendItem(color: AppColors.macroFat, label: 'Fat', value: '${f.round()}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterCard(InsightsData data) {
    final avg = data.avgWater;
    final goal = 2000.0;
    final progress = (avg / goal).clamp(0, 1).toDouble();

    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.waterBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.water_drop_rounded, color: AppColors.waterBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Average Water Intake', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.divider(context),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.waterBlue),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${avg.round()} ml / ${goal.round()} ml (${(progress * 100).round()}%)',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard(InsightsData data) {
    final change = data.weightChange;

    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.weightPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.monitor_weight_rounded, color: AppColors.weightPurple, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weight Trend', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      data.weightHistory.isNotEmpty
                          ? '${data.weightHistory.last.weightKg.toStringAsFixed(1)} kg'
                          : '${data.profile?.weightKg.toStringAsFixed(1) ?? "---"} kg',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.weightPurple),
                    ),
                    const SizedBox(width: 8),
                    if (change != 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (change < 0 ? AppColors.primary : AppColors.error).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${change >= 0 ? "+" : ""}${change.toStringAsFixed(1)} kg',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: change < 0 ? AppColors.primary : AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Goal: ${data.profile?.targetWeightKg.toStringAsFixed(1) ?? "---"} kg',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(InsightsData data) {
    final diff = data.avgCalories - data.prevAvgCalories;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.compare_arrows_rounded, size: 16, color: AppColors.accentBlue),
              ),
              const SizedBox(width: 10),
              Text('Week Over Week', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('This Week', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
                    const SizedBox(height: 4),
                    Text('${data.avgCalories.round()}', style: AppTextStyles.headlineSmall),
                    Text('kcal', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary(context))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (diff <= 0 ? AppColors.primary : AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      diff <= 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                      size: 18,
                      color: diff <= 0 ? AppColors.primary : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${diff >= 0 ? "+" : ""}${diff.round()}',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: diff <= 0 ? AppColors.primary : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Last Week', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
                    const SizedBox(height: 4),
                    Text('${data.prevAvgCalories.round()}', style: AppTextStyles.headlineSmall),
                    Text('kcal', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary(context))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStat(label: 'Days tracked', value: '${data.daysTracked}/7'),
              const SizedBox(width: 24),
              _MiniStat(label: 'Streak', value: '${data.streakDays} days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(InsightsData data) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isGeneratingPdf ? null : () => _generatePdf(data),
        icon: _isGeneratingPdf
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.download_rounded),
        label: Text(_isGeneratingPdf ? 'Generating...' : 'Download PDF Report'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Future<void> _generatePdf(InsightsData data) async {
    if (data.profile == null) return;
    setState(() => _isGeneratingPdf = true);
    try {
      await _pdfService.shareReport(
        profile: data.profile!,
        weekLogs: data.currentWeekLogs,
        previousWeekLogs: data.previousWeekLogs,
        weightHistory: data.weightHistory,
        streakDays: data.streakDays,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to generate PDF report'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: AppTextStyles.titleMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary(context)),
              textAlign: TextAlign.center),
          Text(subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary(context).withValues(alpha: 0.6)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text('$label: $value', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary(context))),
      ],
    );
  }
}
