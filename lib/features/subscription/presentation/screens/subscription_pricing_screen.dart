import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../../domain/models/subscription_model.dart';
import '../providers/subscription_provider.dart';
import 'billing_ledger_screen.dart';
import 'payment_confirmation_screen.dart';

class SubscriptionPricingScreen extends ConsumerStatefulWidget {
  const SubscriptionPricingScreen({super.key});

  @override
  ConsumerState<SubscriptionPricingScreen> createState() =>
      _SubscriptionPricingScreenState();
}

class _SubscriptionPricingScreenState
    extends ConsumerState<SubscriptionPricingScreen> {
  bool _isProcessing = false;

  void _openCheckoutSheet(SubscriptionPlan plan) {
    if (plan.tier == SubscriptionTier.free) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are already on the Free Plan')),
      );
      return;
    }

    String selectedMethod = 'Google Pay';
    bool enableAutoPay = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textColor = isDark ? Colors.white : AppColors.charcoal;
            final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Razorpay Secure Checkout',
                        style: AppTypography.headlineMedium.copyWith(
                          color: textColor,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upgrading to ${plan.title} (₹${plan.pricePerMonth.toInt()}/month)',
                    style: TextStyle(color: mutedTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SELECT UPI PAYMENT METHOD',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.neonLime : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    'Google Pay (Tez)',
                    Icons.account_balance_wallet,
                    selectedMethod == 'Google Pay',
                    () => setSheetState(() => selectedMethod = 'Google Pay'),
                  ),
                  const SizedBox(height: 6),
                  _buildPaymentOption(
                    'PhonePe UPI',
                    Icons.payment,
                    selectedMethod == 'PhonePe',
                    () => setSheetState(() => selectedMethod = 'PhonePe'),
                  ),
                  const SizedBox(height: 6),
                  _buildPaymentOption(
                    'Paytm / Any UPI App',
                    Icons.qr_code,
                    selectedMethod == 'Paytm',
                    () => setSheetState(() => selectedMethod = 'Paytm'),
                  ),
                  const SizedBox(height: 16),
                  // AutoPay Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceElevatedDark : AppColors.softLavender.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.autorenew, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable UPI AutoPay Mandate',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Renews automatically with 48h advance reminder & 1-tap cancel.',
                                style: TextStyle(color: mutedTextColor, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: enableAutoPay,
                          activeThumbColor: AppColors.butterYellow,
                          activeTrackColor: AppColors.blushPink,
                          onChanged: (val) => setSheetState(() => enableAutoPay = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.butterYellow,
                      foregroundColor: AppColors.charcoal,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            _executePayment(plan.tier, selectedMethod, enableAutoPay);
                          },
                    child: Text(
                      'Pay ₹${plan.pricePerMonth.toInt()} via $selectedMethod',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption(String name, IconData icon, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceElevatedDark : AppColors.softLavender.withValues(alpha: 0.35);
    final textColor = isDark ? Colors.white : AppColors.charcoal;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _executePayment(SubscriptionTier tier, String method, bool autoPay) async {
    setState(() => _isProcessing = true);
    try {
      final txn = await ref.read(billingProfileProvider.notifier).subscribe(
            tier: tier,
            paymentMethod: method,
            enableAutoPay: autoPay,
          );
      setState(() => _isProcessing = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentConfirmationScreen(transaction: txn, upgradedTier: tier),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _purchaseUnlock(String type, double price) async {
    setState(() => _isProcessing = true);
    try {
      final txn = await ref.read(billingProfileProvider.notifier).purchaseMicroUnlock(
            unlockType: type,
            amount: price,
            paymentMethod: 'UPI - Instant One-Click',
          );
      if (!mounted) return;
      setState(() => _isProcessing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentConfirmationScreen(transaction: txn),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(availablePlansProvider);
    final billingAsync = ref.watch(billingProfileProvider);
    final activeTier = billingAsync.value?.activeTier ?? SubscriptionTier.free;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.softWhite;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Date² Subscriptions',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long, color: isDark ? AppColors.neonLime : AppColors.primary),
            tooltip: 'Billing Ledger',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BillingLedgerScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Pill
            Row(
              children: [
                Text('Current Status: ', style: TextStyle(color: mutedTextColor, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.softLavender.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.neonLime : AppColors.primary,
                    ),
                  ),
                  child: Text(
                    activeTier == SubscriptionTier.pro
                        ? 'PRO MEMBER 👑'
                        : (activeTier == SubscriptionTier.basic ? 'BASIC MEMBER ⭐' : 'FREE TIER'),
                    style: TextStyle(
                      color: isDark ? AppColors.neonLime : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Plan Cards
            ...plans.map((plan) => _buildPlanCard(plan, activeTier)),

            const SizedBox(height: 28),

            // One-Time Micro Unlocks Section
            Text(
              'ONE-TIME MICRO-UNLOCKS (₹29 - ₹49)',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.neonLime : AppColors.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            _buildMicroUnlockCard(
              title: '1-Hour Profile Super Boost',
              price: '₹29',
              subtitle: 'Place your card at the top of local discovery decks for 60 minutes.',
              icon: Icons.rocket_launch,
              onTap: () => _purchaseUnlock('boost_29', 29.0),
            ),
            const SizedBox(height: 10),
            _buildMicroUnlockCard(
              title: 'Incognito Rewind Pass',
              price: '₹49',
              subtitle: 'Undo past swipes and secretly re-visit missed connections.',
              icon: Icons.replay,
              onTap: () => _purchaseUnlock('rewind_49', 49.0),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, SubscriptionTier currentTier) {
    final isCurrent = plan.tier == currentTier;
    final isPro = plan.isRecommended;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPro
              ? AppColors.blushPink
              : (isCurrent ? AppColors.primary : (isDark ? Colors.white10 : AppColors.softLavender)),
          width: isPro ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPro
                ? AppColors.blushPink.withValues(alpha: 0.25)
                : AppColors.softLavender.withValues(alpha: 0.2),
            blurRadius: isPro ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: const BoxDecoration(
                color: AppColors.butterYellow,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: const Text(
                '★ RECOMMENDED BEST VALUE ★',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.title,
                      style: AppTypography.headlineMedium.copyWith(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plan.pricePerMonth == 0 ? 'FREE' : '₹${plan.pricePerMonth.toInt()}/mo',
                      style: TextStyle(
                        color: isPro ? AppColors.primary : textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.description,
                  style: TextStyle(color: mutedTextColor, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ...plan.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: TextStyle(color: textColor.withValues(alpha: 0.85), fontSize: 12, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrent
                        ? (isDark ? Colors.white12 : Colors.grey.shade200)
                        : (isPro ? AppColors.butterYellow : AppColors.softLavender.withValues(alpha: 0.6)),
                    foregroundColor: isCurrent
                        ? (isDark ? Colors.white54 : Colors.grey)
                        : AppColors.charcoal,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: isPro ? 1 : 0,
                  ),
                  onPressed: isCurrent ? null : () => _openCheckoutSheet(plan),
                  child: Text(
                    isCurrent
                        ? 'Current Plan'
                        : 'Subscribe (${plan.pricePerMonth == 0 ? "Free" : "₹${plan.pricePerMonth.toInt()}/mo"})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroUnlockCard({
    required String title,
    required String price,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.softLavender,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softLavender.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.softLavender.withValues(alpha: 0.5),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: mutedTextColor, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.butterYellow,
              foregroundColor: AppColors.charcoal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
            ),
            onPressed: onTap,
            child: Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
