import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/food_item.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/providers/premium_provider.dart';
import '../../premium/screens/premium_screen.dart';
import '../providers/food_provider.dart';

class AIMealScannerScreen extends ConsumerStatefulWidget {
  const AIMealScannerScreen({super.key});

  @override
  ConsumerState<AIMealScannerScreen> createState() =>
      _AIMealScannerScreenState();
}

class _AIMealScannerScreenState extends ConsumerState<AIMealScannerScreen> {
  final _picker = ImagePicker();
  File? _image;
  bool _isAnalyzing = false;
  String _analysisResult = '';
  String _selectedMeal = 'lunch';
  bool _showForm = false;
  bool _usingGemini = false;

  final _nameController = TextEditingController();
  final _calController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  double _servings = 100;

  @override
  void initState() {
    super.initState();
    _setSuggestedMeal();
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

  void _setSuggestedMeal() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 10) {
        _selectedMeal = 'breakfast';
      } else if (hour < 14) {
        _selectedMeal = 'lunch';
      } else if (hour < 17) {
        _selectedMeal = 'snack';
      } else {
        _selectedMeal = 'dinner';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, maxWidth: 1024);
    if (xFile == null) return;
    setState(() {
      _image = File(xFile.path);
      _isAnalyzing = true;
      _showForm = false;
    });
    await _analyzePhoto(xFile.path);
  }

  Future<void> _analyzePhoto(String path) async {
    final service = AIService();
    final result = await service.analyzePhoto(path);

    if (result != null && mounted) {
      setState(() {
        _isAnalyzing = false;
        _showForm = true;
        _usingGemini = true;
        _analysisResult =
            '${result.name} — ${result.estimatedCalories.round()} cal';
        _nameController.text = result.name;
        _calController.text = result.estimatedCalories.round().toString();
        _proteinController.text = result.estimatedProteinG.toStringAsFixed(1);
        _carbsController.text = result.estimatedCarbsG.toStringAsFixed(1);
        _fatController.text = result.estimatedFatG.toStringAsFixed(1);
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _showForm = true;
        _usingGemini = false;
        _analysisResult = 'AI couldn\'t recognize this meal — please fill in the details';
        _clearFormFields();
      });
    }
  }

  List<Map<String, dynamic>> _getSuggestions() {
    return [
      {
        'name': 'Grilled Chicken Salad',
        'cal': 350,
        'protein': 35,
        'carbs': 10,
        'fat': 18,
      },
      {
        'name': 'Oatmeal with Berries',
        'cal': 280,
        'protein': 10,
        'carbs': 45,
        'fat': 5,
      },
      {
        'name': 'Salmon Bowl',
        'cal': 420,
        'protein': 32,
        'carbs': 30,
        'fat': 16,
      },
      {
        'name': 'Scrambled Eggs & Toast',
        'cal': 320,
        'protein': 22,
        'carbs': 25,
        'fat': 14,
      },
      {
        'name': 'Fruit & Yogurt Smoothie',
        'cal': 230,
        'protein': 12,
        'carbs': 38,
        'fat': 3,
      },
      {
        'name': 'Pasta with Pesto',
        'cal': 400,
        'protein': 12,
        'carbs': 52,
        'fat': 16,
      },
    ];
  }

  void _clearFormFields() {
    _nameController.clear();
    _calController.clear();
    _proteinController.clear();
    _carbsController.clear();
    _fatController.clear();
  }

  void _fillDefaultValues() {
    final suggestions = _getSuggestions();
    final s = suggestions.first;
    _nameController.text = s['name'] as String;
    _calController.text = '${s['cal']}';
    _proteinController.text = '${s['protein']}';
    _carbsController.text = '${s['carbs']}';
    _fatController.text = '${s['fat']}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('AI Meal Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_image == null && !_isAnalyzing)
              _buildPicker()
            else ...[
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_image!, height: 200,
                      width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 20),
              if (_isAnalyzing) _buildAnalyzing(),
              if (_showForm) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_usingGemini
                            ? AppColors.success
                            : AppColors.accentOrange)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _usingGemini
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        color: _usingGemini
                            ? AppColors.success
                            : AppColors.accentOrange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _usingGemini
                              ? 'Analyzed with AI'
                              : _analysisResult,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildForm(),
                const SizedBox(height: 16),
                _buildMealSelector(),
                const SizedBox(height: 12),
                _buildServingSelector(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _addFood,
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPicker() {
    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppColors.divider(context), width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text('Snap a photo of your meal',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 4),
                Text('AI will analyze and estimate nutrition',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Camera'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: AppColors.divider(context)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            setState(() {
              _showForm = true;
              _image = null;
              _fillDefaultValues();
            });
          },
          child: const Text('Enter details manually instead'),
        ),
      ],
    );
  }

  Widget _buildAnalyzing() {
    return const Column(
      children: [
        SizedBox(height: 40),
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text('Analyzing your meal...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        Text('AI is identifying ingredients & estimating nutrition',
            style: TextStyle(color: AppColors.textSecondaryLight)),
      ],
    );
  }

  Widget _buildForm() {
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
          Text('Confirm Details',
              style: AppTextStyles.titleSmall),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Food Name',
              prefixIcon: Icon(Icons.restaurant_rounded),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _calController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    prefixIcon: Icon(Icons.local_fire_department),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _proteinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Protein (g)',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _carbsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Carbs (g)',
                    prefixIcon: Icon(Icons.grain_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _fatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fat (g)',
                    prefixIcon: Icon(Icons.water_drop_rounded),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
                    onTap: () =>
                        setState(() => _selectedMeal = meal['key']!),
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
                onPressed: _servings > 10
                    ? () => setState(() => _servings -= 10)
                    : null,
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
    final cal = double.tryParse(_calController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;

    final food = FoodItem(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.isNotEmpty
          ? _nameController.text
          : 'Unknown Meal',
      servingSizeG: _servings,
      calories: cal * _servings / 100,
      protein: protein * _servings / 100,
      carbs: carbs * _servings / 100,
      fat: fat * _servings / 100,
    );

    await ref.read(dateFoodProvider.notifier).addEntry(
          foodEntryFromFoodItem(food, _selectedMeal),
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
