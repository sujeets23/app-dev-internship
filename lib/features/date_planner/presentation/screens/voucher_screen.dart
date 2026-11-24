import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../../domain/models/date_plan_model.dart';
import '../providers/date_planner_provider.dart';

class VoucherScreen extends ConsumerWidget {
  final DatePlan plan;

  const VoucherScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlan = ref.watch(datePlanStateProvider).value ?? plan;
    final isRedeemed = activePlan.isVoucherRedeemed;

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
          'Digital Partner Voucher',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Voucher Ticket Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isRedeemed ? Colors.white24 : AppColors.softPink,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isRedeemed ? Colors.black : AppColors.softPink).withValues(alpha: 0.2),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Ticket Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isRedeemed
                          ? null
                          : AppColors.blueVioletGradient,
                      color: isRedeemed ? AppColors.surfaceMutedDark : null,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'OFFICIAL PARTNER PASS',
                                style: TextStyle(
                                  color: AppColors.neonLime,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '10% Instant Bill Discount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Middle Voucher Body
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // QR Code Graphic
                        Container(
                          width: 160,
                          height: 160,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: isRedeemed
                              ? const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 64),
                                      SizedBox(height: 4),
                                      Text(
                                        'REDEEMED',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Icon(Icons.qr_code_2, size: 136, color: Colors.black),
                        ),

                        const SizedBox(height: 16),

                        // Cryptographic Code Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            activePlan.digitalVoucherCode ?? 'DATE2-PARTNER-7892X',
                            style: const TextStyle(
                              color: AppColors.neonLime,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Partner Venue Details
                        const Text(
                          'Valid at Partner Venues:',
                          style: TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Subko Coffee • Olive Bistro • Kala Ghoda Art Cafe',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: Colors.white10),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status:', style: TextStyle(color: AppColors.textMutedDark, fontSize: 12)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isRedeemed
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : AppColors.neonLime.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isRedeemed ? 'REDEEMED' : 'READY TO SCAN',
                                style: TextStyle(
                                  color: isRedeemed ? Colors.green : AppColors.neonLime,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Redeem Action Button
            if (!isRedeemed)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Redeem at Venue Cashier (POST /v1/venues/vouchers/redeem)'),
                onPressed: () async {
                  final ok = await ref.read(datePlanStateProvider.notifier).redeemVoucher();
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 10% discount verified & redeemed successfully!'),
                        backgroundColor: AppColors.electricViolet,
                      ),
                    );
                  }
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Voucher has been applied to your bill!',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
