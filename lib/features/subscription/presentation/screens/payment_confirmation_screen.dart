import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../../domain/models/subscription_model.dart';
import 'billing_ledger_screen.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final PaymentTransaction transaction;
  final SubscriptionTier? upgradedTier;

  const PaymentConfirmationScreen({
    super.key,
    required this.transaction,
    this.upgradedTier,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.success.withValues(alpha: 0.16)
                      : AppColors.successLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.success, width: 2),
                ),
                child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 64),
              ),
              const SizedBox(height: 24),
              Text(
                'Demo Entitlement Activated!',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Simulated Demo Gateway (No real UPI payment processed)',
                style: TextStyle(
                  color: isDark ? AppColors.accent : AppColors.accentTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 28),

              // Transaction Receipt Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow(context, 'Item / Plan', transaction.description),
                    Divider(color: border, height: 20),
                    _buildReceiptRow(context, 'Amount Paid', '₹${transaction.amount.toInt()}'),
                    Divider(color: border, height: 20),
                    _buildReceiptRow(context, 'Payment Method', transaction.method),
                    Divider(color: border, height: 20),
                    _buildReceiptRow(context, 'Transaction ID', transaction.transactionId),
                    Divider(color: border, height: 20),
                    _buildReceiptRow(
                      context,
                      'Status',
                      transaction.status,
                      valueColor: AppColors.success,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adaptiveAccent(isDark),
                  foregroundColor: AppColors.adaptiveOnAccent(isDark),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const BillingLedgerScreen()),
                  );
                },
                child: const Text('View Billing Ledger & Mandates', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Return to Home', style: TextStyle(color: textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(BuildContext context, String label, String value, {Color? valueColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textMuted, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
