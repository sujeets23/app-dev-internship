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
    final isInProgress = booking.bookingState == BookingState.inProgress;
    final isCompleted = booking.bookingState == BookingState.completed;
    final telemetryTime = booking.lastTelemetryAt != null
        ? '${booking.lastTelemetryAt!.hour.toString().padLeft(2, '0')}:${booking.lastTelemetryAt!.minute.toString().padLeft(2, '0')}:${booking.lastTelemetryAt!.second.toString().padLeft(2, '0')}'
        : 'ready';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSos
            ? AppColors.error.withValues(alpha: 0.92)
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSos ? AppColors.error : AppColors.accent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSos ? AppColors.error : AppColors.encreDeep)
                .withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: isSos ? Colors.white : AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSos
                      ? 'DEMO SOS TRIGGERED — SIMULATED SAFETY DISPATCH'
                      : (isCompleted
                          ? 'BOOKING COMPLETED • DEMO ESCROW RELEASED'
                          : (isInProgress
                              ? 'ACTIVE SAFETY HUD • DEMO GPS TELEMETRY ($telemetryTime)'
                              : 'BOOKING CONFIRMED • CHECK-IN OTP READY')),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isSos ? Colors.white : AppColors.accent,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (!isSos && !isCompleted)
                InkWell(
                  onTap: () async {
                    final confirmed = await showSosConfirmationDialog(context);
                    if (confirmed == true) {
                      ref.read(activeBookingProvider.notifier).triggerSos();
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
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
                            fontWeight: FontWeight.w700,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${booking.publicVenueName} • GPS ${booking.venueLat.toStringAsFixed(3)}, ${booking.venueLng.toStringAsFixed(3)} • OTP: ${booking.checkInOtp}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondaryDark, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isInProgress)
                TextButton(
                  onPressed: () {
                    ref.read(activeBookingProvider.notifier).completeBooking();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Demo Booking completed! Simulated escrow released.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: const Text('End Booking',
                      style: TextStyle(color: AppColors.accent, fontSize: 12)),
                )
              else if (isCompleted)
                TextButton(
                  onPressed: () =>
                      ref.read(activeBookingProvider.notifier).clearBooking(),
                  child: const Text('Dismiss',
                      style: TextStyle(color: AppColors.accent, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
