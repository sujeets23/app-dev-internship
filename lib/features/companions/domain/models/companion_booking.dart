enum EscrowStatus {
  heldInEscrow,
  releasedToCompanion,
  refunded,
}

enum BookingState {
  pendingConfirmation,
  confirmed,
  inProgress,
  completed,
  cancelled,
  sosTriggered,
}

class CompanionBooking {
  final String id;
  final String companionId;
  final String companionName;
  final String companionAvatar;
  final DateTime scheduledDateTime;
  final int durationHours;
  final String eventCategory;
  final String publicVenueName;
  final String publicVenueAddress;
  final double venueLat;
  final double venueLng;
  final double totalAmount;
  final EscrowStatus escrowStatus;
  final BookingState bookingState;
  final String checkInOtp;
  final String qrCodeToken;
  final bool isGpsTrackingActive;
  final DateTime? checkInTime;
  final DateTime? lastTelemetryAt;

  const CompanionBooking({
    required this.id,
    required this.companionId,
    required this.companionName,
    required this.companionAvatar,
    required this.scheduledDateTime,
    required this.durationHours,
    required this.eventCategory,
    required this.publicVenueName,
    required this.publicVenueAddress,
    required this.venueLat,
    required this.venueLng,
    required this.totalAmount,
    required this.escrowStatus,
    required this.bookingState,
    required this.checkInOtp,
    required this.qrCodeToken,
    this.isGpsTrackingActive = false,
    this.checkInTime,
    this.lastTelemetryAt,
  });

  CompanionBooking copyWith({
    String? id,
    String? companionId,
    String? companionName,
    String? companionAvatar,
    DateTime? scheduledDateTime,
    int? durationHours,
    String? eventCategory,
    String? publicVenueName,
    String? publicVenueAddress,
    double? venueLat,
    double? venueLng,
    double? totalAmount,
    EscrowStatus? escrowStatus,
    BookingState? bookingState,
    String? checkInOtp,
    String? qrCodeToken,
    bool? isGpsTrackingActive,
    DateTime? checkInTime,
    DateTime? lastTelemetryAt,
  }) {
    return CompanionBooking(
      id: id ?? this.id,
      companionId: companionId ?? this.companionId,
      companionName: companionName ?? this.companionName,
      companionAvatar: companionAvatar ?? this.companionAvatar,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      durationHours: durationHours ?? this.durationHours,
      eventCategory: eventCategory ?? this.eventCategory,
      publicVenueName: publicVenueName ?? this.publicVenueName,
      publicVenueAddress: publicVenueAddress ?? this.publicVenueAddress,
      venueLat: venueLat ?? this.venueLat,
      venueLng: venueLng ?? this.venueLng,
      totalAmount: totalAmount ?? this.totalAmount,
      escrowStatus: escrowStatus ?? this.escrowStatus,
      bookingState: bookingState ?? this.bookingState,
      checkInOtp: checkInOtp ?? this.checkInOtp,
      qrCodeToken: qrCodeToken ?? this.qrCodeToken,
      isGpsTrackingActive: isGpsTrackingActive ?? this.isGpsTrackingActive,
      checkInTime: checkInTime ?? this.checkInTime,
      lastTelemetryAt: lastTelemetryAt ?? this.lastTelemetryAt,
    );
  }
}
