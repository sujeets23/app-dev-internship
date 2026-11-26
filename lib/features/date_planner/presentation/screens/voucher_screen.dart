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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

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
          'Digital Partner Voucher',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
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
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isRedeemed
                      ? AppColors.adaptiveBorder(isDark)
                      : (isDark ? AppColors.accent : AppColors.glacierBorder),
                  width: 1.5,
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  // Top Ticket Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isRedeemed ? null : AppColors.encrePrismGradient,
                      color: isRedeemed
                          ? (isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMuted)
                          : null,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: isRedeemed ? mutedColor : AppColors.accent,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OFFICIAL PARTNER PASS',
                                style: TextStyle(
                                  color: isRedeemed ? mutedColor : AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '10% Instant Bill Discount',
                                style: TextStyle(
                                  color: isRedeemed ? textColor : Colors.white,
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
                            border: Border.all(color: AppColors.border),
                          ),
                          child: isRedeemed
                              ? const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: AppColors.success, size: 64),
                                      SizedBox(height: 4),
                                      Text(
                                        'REDEEMED',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Icon(Icons.qr_code_2, size: 136, color: AppColors.encreDeep),
                        ),

                        const SizedBox(height: 16),

                        // Cryptographic Code Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.adaptiveHighlightBg(isDark),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.adaptiveBorder(isDark)),
                          ),
                          child: Text(
                            activePlan.digitalVoucherCode ?? 'DATE2-PARTNER-7892X',
                            style: TextStyle(
                              color: accent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Partner Venue Details
                        Text(
                          'Valid at Partner Venues:',
                          style: TextStyle(color: mutedColor, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Subko Coffee • Olive Bistro • Kala Ghoda Art Cafe',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13),
                        ),

                        const SizedBox(height: 16),
                        Divider(color: AppColors.adaptiveBorder(isDark)),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Status:', style: TextStyle(color: mutedColor, fontSize: 12)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isRedeemed
                                    ? AppColors.success.withValues(alpha: 0.16)
                                    : AppColors.adaptiveHighlightBg(isDark),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isRedeemed ? 'REDEEMED' : 'READY TO SCAN',
                                style: TextStyle(
                                  color: isRedeemed ? AppColors.success : accent,
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
                  backgroundColor: accent,
                  foregroundColor: AppColors.adaptiveOnAccent(isDark),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Redeem at Venue Cashier (POST /v1/venues/vouchers/redeem)'),
                onPressed: () async {
                  final ok = await ref.read(datePlanStateProvider.notifier).redeemVoucher();
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🎉 10% discount verified & redeemed successfully!'),
                        backgroundColor: isDark ? AppColors.encreElevated : AppColors.primary,
                      ),
                    );
                  }
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.45)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    SizedBox(width: 8),
                    Text(
                      'Voucher has been applied to your bill!',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
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
