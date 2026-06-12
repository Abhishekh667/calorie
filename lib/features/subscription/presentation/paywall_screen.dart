import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/subscription_service.dart';
import '../providers/subscription_provider.dart';
import '../models/subscription_plan.dart';
import 'widgets/plan_card.dart';
import 'widgets/premium_benefit_tile.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(subscriptionServiceProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(subscriptionStatusProvider);
    final plans = ref.watch(subscriptionPlansProvider);
    final selectedPlan = ref.watch(selectedPlanProvider);
    final productsAvailable = ref.watch(productsAvailableProvider);
    final error = ref.watch(subscriptionErrorProvider);
    final isRestoring = ref.watch(isRestoringProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Premium'),
        actions: [
          if (status == SubscriptionStatus.subscribed)
            TextButton(
              onPressed: _manageSubscription,
              child: const Text('Manage'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildHeader(),
            const SizedBox(height: 24),
            if (status == SubscriptionStatus.subscribed)
              _buildAlreadySubscribed()
            else ...[
              if (status == SubscriptionStatus.loading && plans.isEmpty && error == null)
                _buildLoading()
              else ...[
                if (!productsAvailable && plans.isNotEmpty)
                  _buildDebugBanner(),
                _buildPlans(plans, selectedPlan),
                const SizedBox(height: 20),
                _buildContinueButton(status, selectedPlan, productsAvailable, isRestoring),
                const SizedBox(height: 12),
                _buildRestoreButton(isRestoring),
                if (status == SubscriptionStatus.subscribed) ...[
                  const SizedBox(height: 12),
                  _buildManageButton(),
                ],
              ],
            ],
            const SizedBox(height: 24),
            _buildBenefits(),
            const SizedBox(height: 24),
            _buildFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            'Calorie Flow Premium',
            style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Unlock the full potential of your fitness journey',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadySubscribed() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 40),
          ),
          const SizedBox(height: 12),
          Text(
            'You are a Premium member!',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: 4),
          Text(
            'Enjoy all premium features',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _manageSubscription,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Manage Subscription'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.accentOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Subscription products are not available. Please check Play Console setup.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading subscription plans...'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlans(List<SubscriptionPlan> plans, SubscriptionPlan? selected) {
    if (plans.isEmpty) return const SizedBox();

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.card_membership_rounded, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'Choose your plan',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...plans.map((plan) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: PlanCard(
            plan: plan,
            isSelected: selected?.id == plan.id,
            onTap: () => ref.read(selectedPlanProvider.notifier).select(plan),
          ),
        )),
      ],
    );
  }

  Widget _buildContinueButton(
    SubscriptionStatus status,
    SubscriptionPlan? selected,
    bool productsAvailable,
    bool isRestoring,
  ) {
    final isLoading = status == SubscriptionStatus.loading || isRestoring;
    final canPurchase = selected != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: canPurchase ? _purchase : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                'Continue',
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildRestoreButton(bool isRestoring) {
    return TextButton(
      onPressed: isRestoring ? null : _restore,
      child: isRestoring
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              'Restore Purchase',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary(context)),
            ),
    );
  }

  Widget _buildManageButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _manageSubscription,
        icon: const Icon(Icons.settings_rounded, size: 18),
        label: const Text('Manage Subscription'),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: AppColors.divider(context)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBenefits() {
    const benefits = [
      {
        'icon': Icons.qr_code_scanner_rounded,
        'title': 'Barcode Scanner',
        'desc': 'Instantly scan packaged foods',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'AI Meal Scanner',
        'desc': 'Snap a photo, log automatically',
        'color': AppColors.accentBlue,
      },
      {
        'icon': Icons.calendar_month_rounded,
        'title': 'Meal Planner',
        'desc': 'Plan your meals for the week',
        'color': AppColors.accentOrange,
      },
      {
        'icon': Icons.insights_rounded,
        'title': 'Advanced Insights',
        'desc': 'Deep analytics and trends',
        'color': AppColors.accentPurple,
      },
      {
        'icon': Icons.picture_as_pdf_rounded,
        'title': 'PDF Report Export',
        'desc': 'Export your progress reports',
        'color': AppColors.calorieRed,
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'Premium Themes',
        'desc': 'Exclusive color themes',
        'color': AppColors.waterBlue,
      },
      {
        'icon': Icons.ad_units_outlined,
        'title': 'No Ads',
        'desc': 'Completely ad-free experience',
        'color': AppColors.success,
      },
    ];

    return Column(
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
              child: const Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'Premium Benefits',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...benefits.map((b) => PremiumBenefitTile(
          icon: b['icon'] as IconData,
          title: b['title'] as String,
          subtitle: b['desc'] as String,
          color: b['color'] as Color,
        )),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Subscription renews automatically unless cancelled in Google Play. You can manage or cancel your subscription anytime from Google Play.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context).withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Terms of Use',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
              ),
            ),
            Container(width: 1, height: 14, color: AppColors.divider(context)),
            TextButton(
              onPressed: () {},
              child: Text(
                'Privacy Policy',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _purchase() async {
    await ref.read(subscriptionServiceProvider).purchase();
    final service = ref.read(subscriptionServiceProvider);
    final status = service.status;

    if (!mounted) return;

    if (status == SubscriptionStatus.subscribed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Welcome to Premium!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } else if (status == SubscriptionStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(service.errorMessage ?? 'Purchase failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (status == SubscriptionStatus.notSubscribed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Purchase cancelled'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _restore() async {
    await ref.read(subscriptionServiceProvider).restorePurchases();
    final service = ref.read(subscriptionServiceProvider);

    if (!mounted) return;

    if (service.status == SubscriptionStatus.subscribed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Purchase restored successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No previous purchases found to restore'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _manageSubscription() {
    ref.read(subscriptionServiceProvider).manageSubscription(context);
  }
}
