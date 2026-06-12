import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/database_provider.dart';
import '../../premium/screens/premium_screen.dart';
import '../providers/settings_provider.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _remindersEnabled = true;
  bool _useImperial = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(settingsProvider.notifier).loadProfile();
      final db = ref.read(databaseServiceProvider);
      final reminders = await db.getRemindersEnabled();
      final imperial = await db.getUseImperial();
      if (mounted) {
        setState(() {
          _remindersEnabled = reminders;
          _useImperial = imperial;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPremiumBanner(),
          const SizedBox(height: 20),
          _buildSection('Profile'),
          const SizedBox(height: 8),
          _buildProfileCard(settings),
          const SizedBox(height: 20),
          _buildSection('Preferences'),
          const SizedBox(height: 8),
          Container(
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
            child: Column(
              children: [
                _buildThemeToggle(themeMode),
                _divider(),
                _buildSettingTile(
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.accentOrange,
                  title: 'Reminders',
                  subtitle: 'Water, meal, weight reminders',
                  trailing: Switch(
                    value: _remindersEnabled,
                    onChanged: _toggleReminders,
                    activeColor: AppColors.primary,
                  ),
                ),
                _divider(),
                _buildSettingTile(
                  icon: Icons.straighten,
                  iconColor: AppColors.accentBlue,
                  title: 'Units',
                  subtitle: _useImperial ? 'Imperial (lbs, ft)' : 'Metric (kg, cm)',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _useImperial ? 'Imperial' : 'Metric',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary(context)),
                    ),
                  ),
                  onTap: _toggleUnits,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection('Calorie Goal'),
          const SizedBox(height: 8),
          _buildCalorieGoalCard(settings),
          const SizedBox(height: 20),
          _buildSection('About'),
          const SizedBox(height: 8),
          Container(
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
            child: Column(
              children: [
                _buildSettingTile(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.accentBlue,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary(context).withValues(alpha: 0.5)),
                  onTap: () {},
                ),
                _divider(),
                _buildSettingTile(
                  icon: Icons.description_outlined,
                  iconColor: AppColors.textSecondary(context),
                  title: 'Terms of Service',
                  trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary(context).withValues(alpha: 0.5)),
                  onTap: () {},
                ),
                _divider(),
                _buildSettingTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.textSecondary(context),
                  title: 'Version',
                  subtitle: '1.0.0',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('1.0.0', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider(context));

  Widget _buildPremiumBanner() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accentBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calorie Flow Premium', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Unlock AI scanning & more', style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(title, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary(context), fontWeight: FontWeight.w600));
  }

  Widget _buildProfileCard(SettingsState settings) {
    final profile = settings.profile;
    if (profile == null) {
      return Container(
        padding: const EdgeInsets.all(20),
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
        child: Center(child: Text('No profile data', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)))),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isNotEmpty ? profile.name : 'User',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.age} yrs · ${profile.gender} · ${_formatHeight(profile.heightCm)} · ${_formatWeight(profile.weightKg)}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
              onPressed: () => _openEditProfile(profile),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHeight(double cm) {
    if (_useImperial) {
      final inches = cm / 2.54;
      final ft = inches ~/ 12;
      final inc = (inches % 12).round();
      return '$ft\'$inc"';
    }
    return '${cm.round()}cm';
  }

  String _formatWeight(double kg) {
    if (_useImperial) {
      final lbs = (kg * 2.20462).round();
      return '$lbs lbs';
    }
    return '${kg.round()}kg';
  }

  Widget _buildCalorieGoalCard(SettingsState settings) {
    final goal = settings.profile?.dailyCalorieGoal ?? 2000;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Daily Target', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${goal.round()}',
            style: AppTextStyles.numberMedium.copyWith(color: AppColors.primary),
          ),
          Text('calories per day', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context))),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditGoal(goal),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Adjust Goal'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(ThemeMode mode) {
    return _buildSettingTile(
      icon: Icons.dark_mode_outlined,
      iconColor: AppColors.accentPurple,
      title: 'Dark Mode',
      subtitle: mode == ThemeMode.dark ? 'Dark theme enabled' : 'Light theme enabled',
      trailing: Switch(
        value: mode == ThemeMode.dark,
        onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context))) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _toggleReminders(bool value) async {
    setState(() => _remindersEnabled = value);
    await ref.read(databaseServiceProvider).setRemindersEnabled(value);
  }

  void _toggleUnits() async {
    final newVal = !_useImperial;
    setState(() => _useImperial = newVal);
    await ref.read(databaseServiceProvider).setUseImperial(newVal);
  }

  void _openEditProfile(UserProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          profile: profile,
          useImperial: _useImperial,
        ),
      ),
    );
  }

  void _showEditGoal(double currentGoal) {
    final controller = TextEditingController(text: currentGoal.round().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Adjust Calorie Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Daily calories',
            suffixText: 'cal',
            filled: true,
            fillColor: AppColors.background(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final goal = double.tryParse(controller.text);
              if (goal != null && goal > 0) {
                ref.read(settingsProvider.notifier).updateCalorieGoal(goal);
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
