import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../../domain/models/subscription_model.dart';
import '../providers/subscription_provider.dart';

class BillingLedgerScreen extends ConsumerWidget {
  const BillingLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingAsync = ref.watch(billingProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final insetBg = isDark ? AppColors.backgroundDark : AppColors.surfaceWarm;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final accent = AppColors.adaptiveAccent(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Billing & Payments Ledger',
          style: AppTypography.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: billingAsync.when(
        data: (profile) {
          final isPro = profile.activeTier == SubscriptionTier.pro;
          final isBasic = profile.activeTier == SubscriptionTier.basic;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 48-Hour Grace Period Notification Banner (if applicable or alert)
                if (profile.inGracePeriod)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.warning.withValues(alpha: 0.16)
                          : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ 48-Hour Renewal Grace Period Active. Please verify your UPI balance.',
                            style: TextStyle(color: textPrimary, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Active Subscription Status Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: (isPro || isBasic)
                        ? (isDark ? AppColors.surfaceElevatedDark : AppColors.glacierLight)
                        : cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isPro
                          ? (isDark ? AppColors.accent : AppColors.primary)
                          : (isBasic
                              ? (isDark ? AppColors.accentTeal : AppColors.glacierBorder)
                              : border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPro
                                ? 'PRO MEMBERSHIP 👑'
                                : (isBasic ? 'BASIC PLAN ⭐' : 'FREE TIER ACCESS'),
                            style: TextStyle(
                              color: isPro ? accent : textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.success.withValues(alpha: 0.2)
                                  : AppColors.successLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile.renewalDate != null
                            ? 'Next Auto-Renewal Date: ${profile.renewalDate!.day}/${profile.renewalDate!.month}/${profile.renewalDate!.year}'
                            : 'No active recurring renewals.',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 14),

                      // UPI AutoPay Mandate Status
                      if (profile.isAutoPayActive && profile.autoPayMandateId != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: insetBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.autorenew, color: accent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mandate: ${profile.autoPayMandateId}',
                                  style: TextStyle(color: textSecondary, fontSize: 11),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final ok = await ref.read(billingProfileProvider.notifier).cancelMandate();
                                  if (ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('UPI AutoPay Mandate successfully cancelled.')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Cancel Mandate',
                                  style: TextStyle(color: AppColors.error, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Payment History Ledger
                Text(
                  'PAYMENT HISTORY LEDGER',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.accent : AppColors.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),

                if (profile.transactionHistory.isEmpty)
                  Center(
                    child: Text('No transaction history found', style: TextStyle(color: textMuted)),
                  )
                else
                  ...profile.transactionHistory.map((txn) => _buildTransactionCard(context, txn)),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: accent),
        ),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, PaymentTransaction txn) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.glacierLight,
            child: Icon(
              Icons.receipt,
              color: AppColors.adaptiveAccent(isDark),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${txn.date.day}/${txn.date.month}/${txn.date.year} • ${txn.method}',
                  style: TextStyle(color: textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${txn.transactionId}',
                  style: TextStyle(color: textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${txn.amount.toInt()}',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                txn.status,
                style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
