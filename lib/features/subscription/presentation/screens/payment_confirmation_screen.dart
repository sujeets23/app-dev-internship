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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                  color: AppColors.neonLime.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonLime, width: 2),
                ),
                child: const Icon(Icons.check_circle_outline, color: AppColors.neonLime, size: 64),
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Verified & Activated!',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Processed via Razorpay Secure Gateway (Test Mode)',
                style: TextStyle(color: AppColors.neonLime, fontSize: 12),
              ),
              const SizedBox(height: 28),

              // Transaction Receipt Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Item / Plan', transaction.description),
                    const Divider(color: Colors.white10, height: 20),
                    _buildReceiptRow('Amount Paid', '₹${transaction.amount.toInt()}'),
                    const Divider(color: Colors.white10, height: 20),
                    _buildReceiptRow('Payment Method', transaction.method),
                    const Divider(color: Colors.white10, height: 20),
                    _buildReceiptRow('Transaction ID', transaction.transactionId),
                    const Divider(color: Colors.white10, height: 20),
                    _buildReceiptRow('Status', transaction.status, valueColor: AppColors.neonLime),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const BillingLedgerScreen()),
                  );
                },
                child: const Text('View Billing Ledger & Mandates', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Return to Home', style: TextStyle(color: AppColors.textMutedDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMutedDark, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
