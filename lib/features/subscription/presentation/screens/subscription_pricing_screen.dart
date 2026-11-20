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
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      const Icon(Icons.shield_outlined, color: AppColors.neonLime),
                      const SizedBox(width: 8),
                      Text(
                        'Razorpay Secure Checkout',
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('TEST MODE', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${plan.title} (Monthly)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${plan.pricePerMonth.toInt()}/mo',
                          style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SELECT UPI PAYMENT METHOD',
                    style: TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentRadioTile('Google Pay', Icons.account_balance_wallet, selectedMethod, (val) {
                    setSheetState(() => selectedMethod = val);
                  }),
                  _buildPaymentRadioTile('PhonePe UPI', Icons.payment, selectedMethod, (val) {
                    setSheetState(() => selectedMethod = val);
                  }),
                  _buildPaymentRadioTile('Paytm UPI', Icons.qr_code, selectedMethod, (val) {
                    setSheetState(() => selectedMethod = val);
                  }),

                  const SizedBox(height: 14),
                  // AutoPay Toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Recurring UPI AutoPay Mandate', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Never miss matches. Cancel anytime with 1-tap in billing settings.', style: TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
                    value: enableAutoPay,
                    activeColor: AppColors.neonLime,
                    onChanged: (val) => setSheetState(() => enableAutoPay = val),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            Navigator.pop(ctx);
                            _executePayment(plan.tier, selectedMethod, enableAutoPay);
                          },
                    child: Text('Pay ₹${plan.pricePerMonth.toInt()} & Authorize Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentRadioTile(String name, IconData icon, String current, Function(String) onSelect) {
    final isSelected = current == name;
    return InkWell(
      onTap: () => onSelect(name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricViolet.withValues(alpha: 0.2) : AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.electricViolet : Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.neonLime : Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.neonLime, size: 18),
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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Date² Subscriptions',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: AppColors.neonLime),
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
                const Text('Current Status: ', style: TextStyle(color: AppColors.textMutedDark, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.neonLime),
                  ),
                  child: Text(
                    activeTier == SubscriptionTier.pro
                        ? 'PRO MEMBER 👑'
                        : (activeTier == SubscriptionTier.basic ? 'BASIC MEMBER ⭐' : 'FREE TIER'),
                    style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 12),
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
                color: AppColors.neonLime,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPro
              ? AppColors.neonLime
              : (isCurrent ? AppColors.electricViolet : Colors.white10),
          width: isPro ? 2 : 1,
        ),
        boxShadow: isPro
            ? [
                BoxShadow(
                  color: AppColors.electricViolet.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPro)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.neonLime,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: const Text(
                '★ RECOMMENDED BEST VALUE ★',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
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
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plan.pricePerMonth == 0 ? 'FREE' : '₹${plan.pricePerMonth.toInt()}/mo',
                      style: TextStyle(
                        color: isPro ? AppColors.neonLime : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.description,
                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ...plan.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check, color: AppColors.neonLime, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
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
                        ? Colors.white12
                        : (isPro ? AppColors.electricViolet : AppColors.surfaceDark),
                    foregroundColor: isCurrent ? Colors.white54 : Colors.white,
                    side: isCurrent ? null : const BorderSide(color: AppColors.electricViolet),
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isCurrent ? null : () => _openCheckoutSheet(plan),
                  child: Text(
                    isCurrent ? 'Current Plan' : 'Subscribe (${plan.pricePerMonth == 0 ? "Free" : "₹${plan.pricePerMonth.toInt()}/mo"})',
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.electricViolet.withValues(alpha: 0.2),
            child: Icon(icon, color: AppColors.neonLime, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonLime,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: onTap,
            child: Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
