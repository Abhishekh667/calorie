import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/food_item.dart';
import '../../../core/services/open_food_facts_service.dart';
import '../../../core/providers/premium_provider.dart';
import '../../premium/screens/premium_screen.dart';
import '../providers/food_provider.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final _scannerController = MobileScannerController();
  final _offService = OpenFoodFactsService();

  bool _isScanning = true;
  bool _isLoading = false;
  FoodItem? _foundFood;
  String? _error;
  String _selectedMeal = 'lunch';
  double _servings = 100;

  @override
  void initState() {
    super.initState();
    _checkPremium();
  }

  Future<void> _checkPremium() async {
    final premium = await ref.read(isPremiumProvider.future);
    if (!premium && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _isLoading) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    _isScanning = false;
    _lookupBarcode(barcode!.rawValue!);
  }

  Future<void> _lookupBarcode(String code) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final food = await _offService.lookupBarcode(code);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (food != null) {
          _foundFood = food;
        } else {
          _error = 'Could not find product for barcode: $code';
          _isScanning = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          if (_foundFood != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                setState(() {
                  _foundFood = null;
                  _error = null;
                  _isScanning = true;
                });
              },
            ),
        ],
      ),
      body: _foundFood != null ? _buildResult() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Looking up product...',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        if (_error != null)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isScanning = true;
                      });
                    },
                    child: const Text('Try Again',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Point camera at a barcode',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final food = _foundFood!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider(context)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 48),
                ),
                const SizedBox(height: 16),
                Text(food.name,
                    style: AppTextStyles.titleLarge,
                    textAlign: TextAlign.center),
                if (food.brand.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(food.brand,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary(context))),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNutrient('Calories',
                        '${food.calories.round()}', 'kcal'),
                    _buildNutrient(
                        'Protein', '${food.protein.toStringAsFixed(1)}', 'g'),
                    _buildNutrient('Carbs',
                        '${food.carbs.toStringAsFixed(1)}', 'g'),
                    _buildNutrient(
                        'Fat', '${food.fat.toStringAsFixed(1)}', 'g'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildMealSelector(),
          const SizedBox(height: 12),
          _buildServingSelector(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => _addFood(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Add to Diary',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrient(String label, String value, String unit) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary(context))),
        Text(unit,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary(context))),
        const SizedBox(height: 2),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textSecondary(context))),
      ],
    );
  }

  Widget _buildMealSelector() {
    const meals = [
      {'key': 'breakfast', 'label': 'Breakfast'},
      {'key': 'lunch', 'label': 'Lunch'},
      {'key': 'dinner', 'label': 'Dinner'},
      {'key': 'snack', 'label': 'Snack'},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meal', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: meals.map((meal) {
              final selected = _selectedMeal == meal['key'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMeal = meal['key']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.background(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider(context),
                        ),
                      ),
                      child: Text(
                        meal['label']!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServingSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Serving Size', style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed:
                    _servings > 10 ? () => setState(() => _servings -= 10) : null,
              ),
              Text('${_servings.round()}g',
                  style: AppTextStyles.titleLarge),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => setState(() => _servings += 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addFood() async {
    final food = _foundFood!;
    final adjustedCal = (food.calories * _servings / food.servingSizeG).round();
    final adjustedProtein = food.protein * _servings / food.servingSizeG;
    final adjustedCarbs = food.carbs * _servings / food.servingSizeG;
    final adjustedFat = food.fat * _servings / food.servingSizeG;

    final servingFood = food.copyWith(
      calories: adjustedCal.toDouble(),
      protein: adjustedProtein,
      carbs: adjustedCarbs,
      fat: adjustedFat,
      servingSizeG: _servings,
    );

    await ref.read(dateFoodProvider.notifier).addEntry(
          foodEntryFromFoodItem(servingFood, _selectedMeal),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Food added successfully!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}