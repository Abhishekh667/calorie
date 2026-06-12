import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/food_entry.dart';
import '../../../core/models/food_item.dart';
import '../../../core/providers/premium_provider.dart';
import '../../premium/screens/premium_screen.dart';
import '../providers/food_provider.dart';
import '../widgets/meal_section.dart';
import 'barcode_scanner_screen.dart';
import 'ai_meal_scanner_screen.dart';

class FoodDiaryScreen extends ConsumerStatefulWidget {
  final String mealType;
  final DateTime? date;

  const FoodDiaryScreen({
    super.key,
    this.mealType = 'all',
    this.date,
  });

  @override
  ConsumerState<FoodDiaryScreen> createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends ConsumerState<FoodDiaryScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMeal = 'all';

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.mealType;
    Future.microtask(() {
      ref.read(dateFoodProvider.notifier).loadEntries(_selectedDate);
    });
  }

  void _goToDate(DateTime date) {
    setState(() => _selectedDate = date);
    ref.read(dateFoodProvider.notifier).loadEntries(date);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dateFoodProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Food Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showAddFood(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateBar(),
          _buildMealTabs(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFoodList(state.entries),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBar() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
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
            child: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 22),
              onPressed: () => _goToDate(_selectedDate.subtract(const Duration(days: 1))),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textPrimary(context),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showDatePicker(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    isToday ? 'Today' : DateFormat('MMM d, yyyy').format(_selectedDate),
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textSecondary(context)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
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
            child: IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 22),
              onPressed: isToday
                  ? null
                  : () => _goToDate(_selectedDate.add(const Duration(days: 1))),
              style: IconButton.styleFrom(
                foregroundColor: isToday ? AppColors.textSecondary(context).withValues(alpha: 0.4) : AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) _goToDate(picked);
  }

  Widget _buildMealTabs() {
    const meals = [
      {'key': 'all', 'label': 'All'},
      {'key': 'breakfast', 'label': 'Breakfast'},
      {'key': 'lunch', 'label': 'Lunch'},
      {'key': 'dinner', 'label': 'Dinner'},
      {'key': 'snack', 'label': 'Snacks'},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: meals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final meal = meals[index];
          final selected = _selectedMeal == meal['key'];
          return GestureDetector(
            onTap: () => setState(() => _selectedMeal = meal['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider(context),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  meal['label']!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary(context),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodList(List<FoodEntry> entries) {
    final filtered = _selectedMeal == 'all'
        ? entries
        : entries.where((e) => e.mealType == _selectedMeal).toList();

    final meals = <String, List<FoodEntry>>{};
    for (final e in filtered) {
      meals.putIfAbsent(e.mealType, () => []);
      meals[e.mealType]!.add(e);
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.restaurant_rounded, size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text('No entries yet', style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text('Tap + to add your first meal', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _showAddFood(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Food'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (meals.containsKey('breakfast'))
          MealSection(
            title: 'Breakfast',
            icon: Icons.wb_sunny_rounded,
            entries: meals['breakfast']!,
          ),
        if (meals.containsKey('lunch'))
          MealSection(
            title: 'Lunch',
            icon: Icons.cloud_rounded,
            entries: meals['lunch']!,
          ),
        if (meals.containsKey('dinner'))
          MealSection(
            title: 'Dinner',
            icon: Icons.nights_stay_rounded,
            entries: meals['dinner']!,
          ),
        if (meals.containsKey('snack'))
          MealSection(
            title: 'Snacks',
            icon: Icons.cookie,
            entries: meals['snack']!,
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  void _showAddFood(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddFoodScreen()),
    );
  }
}

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _searchController = TextEditingController();
  String _selectedMeal = 'lunch';
  double _servings = 100;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(foodSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Add Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Barcode Scan',
            onPressed: () => _openBarcodeScanner(context),
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded),
            tooltip: 'AI Meal Scan',
            onPressed: () => _openAIMealScanner(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search food...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.card(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(foodSearchProvider.notifier).clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (v) => ref.read(foodSearchProvider.notifier).search(v),
            ),
          ),
          _buildMealSelector(),
          _buildServingSelector(),
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: searchState.results.length,
                    itemBuilder: (context, index) {
                      final food = searchState.results[index];
                      return _FoodItemTile(
                        food: food,
                        servings: _servings,
                        onTap: () => _addFood(food),
                      );
                    },
                  ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: meals.map((meal) {
          final selected = _selectedMeal == meal['key'];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => setState(() => _selectedMeal = meal['key']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.divider(context),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    meal['label']!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: selected ? Colors.white : AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServingSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 4),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.speed_rounded, size: 16, color: AppColors.textSecondary(context)),
          const SizedBox(width: 8),
          Text('Serving:', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context))),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.remove_rounded, size: 18),
              onPressed: _servings > 10 ? () => setState(() => _servings -= 10) : null,
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textPrimary(context),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${_servings.round()}g', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, size: 18),
              onPressed: () => setState(() => _servings += 10),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textPrimary(context),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addFood(FoodItem food) async {
    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodItemId: food.id,
      mealType: _selectedMeal,
      date: DateTime.now(),
      servings: _servings,
      foodItem: food,
    );
    await ref.read(dateFoodProvider.notifier).addEntry(entry);
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

  Future<void> _openBarcodeScanner(BuildContext context) async {
    final premium = await ref.read(isPremiumProvider.future);
    if (!premium && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
      return;
    }
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
      );
    }
  }

  Future<void> _openAIMealScanner(BuildContext context) async {
    final premium = await ref.read(isPremiumProvider.future);
    if (!premium && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      );
      return;
    }
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AIMealScannerScreen()),
      );
    }
  }
}

class _FoodItemTile extends StatelessWidget {
  final FoodItem food;
  final double servings;
  final VoidCallback onTap;

  const _FoodItemTile({
    required this.food,
    required this.servings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cal = (food.calories * servings / food.servingSizeG).round();
    final p = (food.protein * servings / food.servingSizeG).toStringAsFixed(1);
    final c = (food.carbs * servings / food.servingSizeG).toStringAsFixed(1);
    final f = (food.fat * servings / food.servingSizeG).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(
                        'P: $p · C: $c · F: $f',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$cal', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    Text('cal', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
