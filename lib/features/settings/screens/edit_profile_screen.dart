import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/user_profile.dart';
import '../providers/settings_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;
  final bool useImperial;

  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.useImperial,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _targetCtrl;
  late String _gender;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _ageCtrl = TextEditingController(text: widget.profile.age.toString());
    _heightCtrl = TextEditingController(text: widget.profile.heightCm.round().toString());
    _weightCtrl = TextEditingController(text: widget.profile.weightKg.round().toString());
    _targetCtrl = TextEditingController(text: widget.profile.targetWeightKg.round().toString());
    _gender = widget.profile.gender;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMetric = !widget.useImperial;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildField(
            controller: _nameCtrl,
            label: 'Name',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _ageCtrl,
            label: 'Age',
            icon: Icons.cake_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary(context).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gender', style: AppTextStyles.titleSmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _GenderOption(
                        icon: Icons.male_rounded,
                        label: 'Male',
                        isSelected: _gender == 'male',
                        onTap: () => setState(() => _gender = 'male'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderOption(
                        icon: Icons.female_rounded,
                        label: 'Female',
                        isSelected: _gender == 'female',
                        onTap: () => setState(() => _gender = 'female'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GenderOption(
                        icon: Icons.transgender_rounded,
                        label: 'Other',
                        isSelected: _gender == 'other',
                        onTap: () => setState(() => _gender = 'other'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _heightCtrl,
            label: 'Height',
            icon: Icons.height_rounded,
            suffix: isMetric ? 'cm' : 'in',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _weightCtrl,
            label: 'Weight',
            icon: Icons.monitor_weight_rounded,
            suffix: isMetric ? 'kg' : 'lbs',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _targetCtrl,
            label: 'Target Weight',
            icon: Icons.flag_rounded,
            suffix: isMetric ? 'kg' : 'lbs',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              suffixText: suffix,
              filled: true,
              fillColor: AppColors.background(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final age = int.tryParse(_ageCtrl.text) ?? widget.profile.age;
    final height = double.tryParse(_heightCtrl.text);
    final weight = double.tryParse(_weightCtrl.text);
    final target = double.tryParse(_targetCtrl.text);
    if (height == null || weight == null || target == null) return;

    double heightCm = height;
    double weightKg = weight;
    double targetKg = target;
    if (widget.useImperial) {
      heightCm = height * 2.54;
      weightKg = weight / 2.20462;
      targetKg = target / 2.20462;
    }

    final updated = widget.profile.copyWith(
      name: _nameCtrl.text,
      age: age,
      gender: _gender,
      heightCm: heightCm,
      weightKg: weightKg,
      targetWeightKg: targetKg,
    );
    ref.read(settingsProvider.notifier).updateProfile(updated);
    Navigator.of(context).pop();
  }
}

class _GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary(context), size: 24),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary(context),
            )),
          ],
        ),
      ),
    );
  }
}
