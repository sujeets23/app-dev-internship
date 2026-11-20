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
          'Billing & Payments Ledger',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
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
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ 48-Hour Renewal Grace Period Active. Please verify your UPI balance.',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Active Subscription Status Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isPro ? AppColors.neonLime : (isBasic ? AppColors.electricViolet : Colors.white12),
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
                              color: isPro ? AppColors.neonLime : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ACTIVE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile.renewalDate != null
                            ? 'Next Auto-Renewal Date: ${profile.renewalDate!.day}/${profile.renewalDate!.month}/${profile.renewalDate!.year}'
                            : 'No active recurring renewals.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 14),

                      // UPI AutoPay Mandate Status
                      if (profile.isAutoPayActive && profile.autoPayMandateId != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.autorenew, color: AppColors.neonLime, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mandate: ${profile.autoPayMandateId}',
                                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11),
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
                                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
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
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonLime,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),

                if (profile.transactionHistory.isEmpty)
                  const Center(
                    child: Text('No transaction history found', style: TextStyle(color: AppColors.textMutedDark)),
                  )
                else
                  ...profile.transactionHistory.map((txn) => _buildTransactionCard(txn)),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.electricViolet),
        ),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildTransactionCard(PaymentTransaction txn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            child: const Icon(Icons.receipt, color: AppColors.neonLime, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${txn.date.day}/${txn.date.month}/${txn.date.year} • ${txn.method}',
                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${txn.transactionId}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${txn.amount.toInt()}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                txn.status,
                style: const TextStyle(color: AppColors.neonLime, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
