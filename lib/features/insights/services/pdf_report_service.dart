import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/daily_log.dart';
import '../../../core/models/weight_entry.dart';
import '../../../core/services/calorie_calculator.dart';

class PdfReportService {
  Future<Uint8List> generateReport({
    required UserProfile profile,
    required List<DailyLog> weekLogs,
    required List<DailyLog> previousWeekLogs,
    required List<WeightEntry> weightHistory,
    required int streakDays,
  }) async {
    final pdf = pw.Document();

    final avgCal = weekLogs.isEmpty
        ? 0.0
        : weekLogs.fold<double>(0, (s, l) => s + l.totalCalories) / weekLogs.length;
    final prevAvgCal = previousWeekLogs.isEmpty
        ? 0.0
        : previousWeekLogs.fold<double>(0, (s, l) => s + l.totalCalories) / previousWeekLogs.length;
    final totalCal = weekLogs.fold<double>(0, (s, l) => s + l.totalCalories);
    final avgWater = weekLogs.isEmpty
        ? 0.0
        : weekLogs.fold<double>(0, (s, l) => s + l.totalWaterMl) / weekLogs.length;
    final avgProtein = weekLogs.isEmpty
        ? 0.0
        : weekLogs.fold<double>(0, (s, l) => s + l.totalProtein) / weekLogs.length;
    final avgCarbs = weekLogs.isEmpty
        ? 0.0
        : weekLogs.fold<double>(0, (s, l) => s + l.totalCarbs) / weekLogs.length;
    final avgFat = weekLogs.isEmpty
        ? 0.0
        : weekLogs.fold<double>(0, (s, l) => s + l.totalFat) / weekLogs.length;

    final macros = CalorieCalculator.getMacroSplit(
      calories: profile.dailyCalorieGoal,
      goal: profile.goal,
    );

    final weightChange = weightHistory.length >= 2
        ? weightHistory.last.weightKg - weightHistory.first.weightKg
        : 0.0;
    final latestWeight = weightHistory.isNotEmpty ? weightHistory.last.weightKg : profile.weightKg;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Text('Calorie Flow - Nutrition Report',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text('Generated on ${_formatDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        ),
        build: (context) => [
          _sectionTitle('Profile Summary'),
          _infoRow('Name', profile.name.isNotEmpty ? profile.name : 'User'),
          _infoRow('Goal', CalorieCalculator.getGoalLabel(profile.goal)),
          _infoRow('Daily Calorie Target', '${profile.dailyCalorieGoal.round()} kcal'),
          _infoRow('Current Weight', '${latestWeight.toStringAsFixed(1)} kg'),
          _infoRow('Target Weight', '${profile.targetWeightKg.toStringAsFixed(1)} kg'),
          _infoRow('Activity Level', CalorieCalculator.getActivityLevelLabel(profile.activityLevel)),
          _infoRow('BMR', '${CalorieCalculator.calculateBMR(
            weightKg: profile.weightKg,
            heightCm: profile.heightCm,
            age: profile.age,
            gender: profile.gender,
          ).round()} kcal/day'),
          pw.SizedBox(height: 20),

          _sectionTitle('This Week Overview ($_dateRange(weekLogs))'),
          _infoRow('Total Calories Consumed', '${totalCal.round()} kcal'),
          _infoRow('Daily Average', '${avgCal.round()} kcal'),
          _infoRow('Target Average', '${profile.dailyCalorieGoal.round()} kcal'),
          _infoRow('Average Water Intake', '${avgWater.round()} ml'),
          _infoRow('Days Tracked', '${weekLogs.where((l) => l.totalCalories > 0).length} / 7'),
          _infoRow('Current Streak', '$streakDays days'),
          pw.SizedBox(height: 20),

          _sectionTitle('Macro Breakdown (7-Day Average)'),
          _infoRow('Protein (Target: ${macros['proteinG']!.round()}g)',
              '${avgProtein.round()}g - ${macros['proteinG']! > 0 ? (avgProtein / macros['proteinG']! * 100).round() : 0}% of target'),
          _infoRow('Carbs (Target: ${macros['carbsG']!.round()}g)',
              '${avgCarbs.round()}g - ${macros['carbsG']! > 0 ? (avgCarbs / macros['carbsG']! * 100).round() : 0}% of target'),
          _infoRow('Fat (Target: ${macros['fatG']!.round()}g)',
              '${avgFat.round()}g - ${macros['fatG']! > 0 ? (avgFat / macros['fatG']! * 100).round() : 0}% of target'),
          pw.SizedBox(height: 20),

          _sectionTitle('Previous Week Comparison'),
          _infoRow('Current Week Avg', '${avgCal.round()} kcal/day'),
          _infoRow('Previous Week Avg', '${prevAvgCal.round()} kcal/day'),
          _infoRow('Change',
              '${avgCal > prevAvgCal ? "+" : ""}${(avgCal - prevAvgCal).round()} kcal/day'),
          pw.SizedBox(height: 20),

          _sectionTitle('Weight Summary'),
          _infoRow('Current Weight', '${latestWeight.toStringAsFixed(1)} kg'),
          _infoRow('Total Change',
              '${weightChange >= 0 ? "+" : ""}${weightChange.toStringAsFixed(1)} kg'),
          _infoRow('Entries Logged', '${weightHistory.length}'),
          pw.SizedBox(height: 20),

          pw.Paragraph(
            text:
                'This report was automatically generated by Calorie Flow. Data is based on manually logged entries and may not reflect 100% accuracy. For medical advice, please consult a healthcare professional.',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey, fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> shareReport({
    required UserProfile profile,
    required List<DailyLog> weekLogs,
    required List<DailyLog> previousWeekLogs,
    required List<WeightEntry> weightHistory,
    required int streakDays,
  }) async {
    final pdf = await generateReport(
      profile: profile,
      weekLogs: weekLogs,
      previousWeekLogs: previousWeekLogs,
      weightHistory: weightHistory,
      streakDays: streakDays,
    );

    await Printing.sharePdf(
      bytes: pdf,
      filename: 'calorie_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<void> saveReport({
    required UserProfile profile,
    required List<DailyLog> weekLogs,
    required List<DailyLog> previousWeekLogs,
    required List<WeightEntry> weightHistory,
    required int streakDays,
  }) async {
    final pdf = await generateReport(
      profile: profile,
      weekLogs: weekLogs,
      previousWeekLogs: previousWeekLogs,
      weightHistory: weightHistory,
      streakDays: streakDays,
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/calorie_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(pdf);
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _dateRange(List<DailyLog> logs) {
    if (logs.isEmpty) return 'No data';
    final start = logs.first.date;
    final end = logs.last.date;
    return '${start.month}/${start.day} - ${end.month}/${end.day}';
  }
}
