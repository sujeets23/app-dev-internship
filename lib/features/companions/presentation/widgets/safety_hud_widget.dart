import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import '../../domain/models/companion_booking.dart';
import '../providers/companion_provider.dart';
import 'sos_dialog.dart';

class SafetyHudWidget extends ConsumerWidget {
  const SafetyHudWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(activeBookingProvider);
    if (booking == null) return const SizedBox.shrink();

    final isSos = booking.bookingState == BookingState.sosTriggered;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSos
            ? Colors.red.withValues(alpha: 0.9)
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSos ? Colors.redAccent : AppColors.neonLime,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSos ? Colors.red : AppColors.neonLime).withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSos ? Colors.white : AppColors.neonLime,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSos
                      ? '🚨 EMERGENCY SOS ACTIVE - HELP DISPATCHED'
                      : 'SAFETY ESCROW HUD • GPS MONITORING ON',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSos ? Colors.white : AppColors.neonLime,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (!isSos)
                InkWell(
                  onTap: () async {
                    final confirmed = await showSosConfirmationDialog(context);
                    if (confirmed == true) {
                      ref.read(activeBookingProvider.notifier).triggerSos();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sos, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(booking.companionAvatar),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'With ${booking.companionName} (${booking.eventCategory})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${booking.publicVenueName} • OTP: ${booking.checkInOtp}',
                      style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (booking.bookingState == BookingState.inProgress)
                TextButton(
                  onPressed: () {
                    ref.read(activeBookingProvider.notifier).completeBooking();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking completed! Escrow released to companion.'),
                        backgroundColor: AppColors.electricViolet,
                      ),
                    );
                  },
                  child: const Text('End Booking', style: TextStyle(color: AppColors.softPink, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
