import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/companion_service.dart';
import '../../domain/models/companion_model.dart';
import '../../domain/models/companion_booking.dart';

final companionServiceProvider = Provider<ICompanionService>((ref) {
  return MockCompanionService();
});

class CompanionFilterState {
  final String category;
  final double maxRate;
  final String language;
  final double minRating;
  final String searchQuery;

  const CompanionFilterState({
    this.category = 'All',
    this.maxRate = 2000.0,
    this.language = 'All',
    this.minRating = 0.0,
    this.searchQuery = '',
  });

  CompanionFilterState copyWith({
    String? category,
    double? maxRate,
    String? language,
    double? minRating,
    String? searchQuery,
  }) {
    return CompanionFilterState(
      category: category ?? this.category,
      maxRate: maxRate ?? this.maxRate,
      language: language ?? this.language,
      minRating: minRating ?? this.minRating,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CompanionFilterNotifier extends Notifier<CompanionFilterState> {
  @override
  CompanionFilterState build() => const CompanionFilterState();

  void setFilter(CompanionFilterState filter) => state = filter;
  void updateCategory(String category) => state = state.copyWith(category: category);
  void updateMaxRate(double rate) => state = state.copyWith(maxRate: rate);
  void updateSearch(String query) => state = state.copyWith(searchQuery: query);
}

final companionFilterProvider =
    NotifierProvider<CompanionFilterNotifier, CompanionFilterState>(
  CompanionFilterNotifier.new,
);

final companionsListProvider =
    FutureProvider.autoDispose<List<CompanionModel>>((ref) async {
  final service = ref.watch(companionServiceProvider);
  final filter = ref.watch(companionFilterProvider);

  final list = await service.fetchCompanions(
    category: filter.category == 'All' ? null : filter.category,
    maxRate: filter.maxRate,
    language: filter.language == 'All' ? null : filter.language,
    minRating: filter.minRating > 0 ? filter.minRating : null,
  );

  if (filter.searchQuery.trim().isEmpty) return list;

  final q = filter.searchQuery.toLowerCase();
  return list.where((c) {
    return c.name.toLowerCase().contains(q) ||
        c.tagLine.toLowerCase().contains(q) ||
        c.specialties.any((s) => s.toLowerCase().contains(q));
  }).toList();
});

class ActiveBookingNotifier extends Notifier<CompanionBooking?> {
  Timer? _gpsTimer;
  ICompanionService get _service => ref.read(companionServiceProvider);

  @override
  CompanionBooking? build() {
    ref.onDispose(() {
      _gpsTimer?.cancel();
    });
    return null;
  }

  void setBooking(CompanionBooking booking) {
    state = booking;
    _startGpsHeartbeat();
  }

  void _startGpsHeartbeat() {
    _gpsTimer?.cancel();
    if (state != null && state!.isGpsTrackingActive) {
      _gpsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (state != null && state!.bookingState == BookingState.inProgress) {
          // Live background GPS location updates at fixed intervals
        }
      });
    }
  }

  Future<void> checkIn(String otp) async {
    if (state == null) return;
    final updated = await _service.checkInWithOtp(bookingId: state!.id, otp: otp);
    state = updated;
  }

  Future<void> triggerSos() async {
    if (state == null) return;
    await _service.triggerEmergencySos(
      bookingId: state!.id,
      currentLat: state!.venueLat,
      currentLng: state!.venueLng,
    );
    state = state!.copyWith(bookingState: BookingState.sosTriggered);
  }

  void completeBooking() {
    if (state == null) return;
    state = state!.copyWith(
      bookingState: BookingState.completed,
      escrowStatus: EscrowStatus.releasedToCompanion,
      isGpsTrackingActive: false,
    );
    _gpsTimer?.cancel();
  }

  void clearBooking() {
    _gpsTimer?.cancel();
    state = null;
  }
}

final activeBookingProvider =
    NotifierProvider<ActiveBookingNotifier, CompanionBooking?>(
  ActiveBookingNotifier.new,
);
