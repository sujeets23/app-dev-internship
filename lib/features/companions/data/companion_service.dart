import 'dart:async';
import '../domain/models/companion_model.dart';
import '../domain/models/companion_booking.dart';

abstract class ICompanionService {
  Future<List<CompanionModel>> fetchCompanions({
    String? category,
    double? maxRate,
    String? language,
    double? minRating,
  });
  Future<CompanionModel?> getCompanionDetails(String id);
  Future<CompanionBooking> createBooking({
    required String companionId,
    required DateTime dateTime,
    required int durationHours,
    required String eventCategory,
    required String venueName,
    required String venueAddress,
    required double venueLat,
    required double venueLng,
    required double hourlyRate,
  });
  Future<CompanionBooking> checkInWithOtp({
    required String bookingId,
    required String otp,
  });
  Future<void> triggerEmergencySos({
    required String bookingId,
    required double currentLat,
    required double currentLng,
  });
}

class ProductionCompanionService implements ICompanionService {
  final String baseUrl;
  ProductionCompanionService({this.baseUrl = 'https://api.date2.app'});

  @override
  Future<List<CompanionModel>> fetchCompanions({
    String? category,
    double? maxRate,
    String? language,
    double? minRating,
  }) =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<CompanionModel?> getCompanionDetails(String id) =>
      throw UnimplementedError('Backend server offline');

  @override
  Future<CompanionBooking> createBooking({
    required String companionId,
    required DateTime dateTime,
    required int durationHours,
    required String eventCategory,
    required String venueName,
    required String venueAddress,
    required double venueLat,
    required double venueLng,
    required double hourlyRate,
  }) =>
      throw UnimplementedError('POST /v1/companions/bookings backend offline');

  @override
  Future<CompanionBooking> checkInWithOtp({
    required String bookingId,
    required String otp,
  }) =>
      throw UnimplementedError('POST /v1/bookings/{id}/checkin backend offline');

  @override
  Future<void> triggerEmergencySos({
    required String bookingId,
    required double currentLat,
    required double currentLng,
  }) =>
      throw UnimplementedError('POST /v1/bookings/{id}/sos backend offline');
}

class MockCompanionService implements ICompanionService {
  final List<CompanionModel> _companions = [
    CompanionModel(
      id: 'comp_1',
      name: 'Advika Sengupta',
      age: 26,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      photos: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600',
      ],
      tagLine: 'Art curator & conversationalist for gallery events & theater',
      bio:
          'Passionate about contemporary South Asian art, classical literature, and indie cinema. Ideal companion for art exhibition previews, literary festivals, and sophisticated dinners.',
      hourlyRate: 850.0,
      languages: ['English', 'Hindi', 'Bengali'],
      specialties: ['Gallery & Arts', 'Theater', 'Formal Dinner'],
      rating: 4.95,
      reviewCount: 38,
      isVerified: true,
      isBackgroundChecked: true,
      reviews: const [
        CompanionReview(
          id: 'rev_1',
          userName: 'Karan M.',
          rating: 5.0,
          comment: 'Advika was the perfect companion for the gallery opening. Incredibly knowledgeable and articulate!',
          date: '2 weeks ago',
        ),
        CompanionReview(
          id: 'rev_2',
          userName: 'Pooja S.',
          rating: 4.9,
          comment: 'Made attending the theatre solo feel celebratory and comfortable. Felt completely safe throughout.',
          date: '1 month ago',
        ),
      ],
    ),
    CompanionModel(
      id: 'comp_2',
      name: 'Rohan Mehra',
      age: 28,
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      photos: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=600',
      ],
      tagLine: 'Tech founder & host for networking galas & industry expos',
      bio:
          'Comfortable in corporate summits, angel investor dinners, and tech gatherings. Great conversationalist who can adapt to any professional or casual social environment.',
      hourlyRate: 1100.0,
      languages: ['English', 'Hindi', 'Punjabi'],
      specialties: ['Tech Conference', 'Business Dinner', 'City Tour'],
      rating: 4.88,
      reviewCount: 45,
      isVerified: true,
      isBackgroundChecked: true,
      reviews: const [
        CompanionReview(
          id: 'rev_3',
          userName: 'Vikram B.',
          rating: 5.0,
          comment: 'Excellent wingman at the tech mixer! Helped break the ice with several founders.',
          date: '3 weeks ago',
        ),
      ],
    ),
    CompanionModel(
      id: 'comp_3',
      name: 'Kyra D\'souza',
      age: 24,
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      photos: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600',
      ],
      tagLine: 'Queer-friendly culinary explorer & indie gig companion',
      bio:
          'Love discovering hole-in-the-wall cafes, artisanal coffee roasters, and live jazz or acoustic indie gigs. Warm, welcoming, and 100% inclusive safe space.',
      hourlyRate: 650.0,
      languages: ['English', 'Hindi', 'Konkani'],
      specialties: ['Queer Social', 'Foodie Tours', 'Concerts'],
      rating: 4.92,
      reviewCount: 29,
      isVerified: true,
      isBackgroundChecked: true,
      reviews: const [
        CompanionReview(
          id: 'rev_4',
          userName: 'Sam V.',
          rating: 5.0,
          comment: 'Kyra is an absolute delight! Felt so safe and had a blast at the music fest.',
          date: '4 days ago',
        ),
      ],
    ),
  ];

  @override
  Future<List<CompanionModel>> fetchCompanions({
    String? category,
    double? maxRate,
    String? language,
    double? minRating,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _companions.where((c) {
      if (category != null && category.isNotEmpty && category != 'All') {
        if (!c.specialties.any((s) => s.toLowerCase().contains(category.toLowerCase()))) {
          return false;
        }
      }
      if (maxRate != null && c.hourlyRate > maxRate) {
        return false;
      }
      if (language != null && language.isNotEmpty && language != 'All') {
        if (!c.languages.contains(language)) {
          return false;
        }
      }
      if (minRating != null && c.rating < minRating) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<CompanionModel?> getCompanionDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _companions.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CompanionBooking> createBooking({
    required String companionId,
    required DateTime dateTime,
    required int durationHours,
    required String eventCategory,
    required String venueName,
    required String venueAddress,
    required double venueLat,
    required double venueLng,
    required double hourlyRate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final comp = _companions.firstWhere((c) => c.id == companionId);
    final bookingId = 'bk_${DateTime.now().millisecondsSinceEpoch}';

    return CompanionBooking(
      id: bookingId,
      companionId: comp.id,
      companionName: comp.name,
      companionAvatar: comp.avatarUrl,
      scheduledDateTime: dateTime,
      durationHours: durationHours,
      eventCategory: eventCategory,
      publicVenueName: venueName,
      publicVenueAddress: venueAddress,
      venueLat: venueLat,
      venueLng: venueLng,
      totalAmount: durationHours * hourlyRate,
      escrowStatus: EscrowStatus.heldInEscrow,
      bookingState: BookingState.confirmed,
      checkInOtp: '7492',
      qrCodeToken: 'DATE2-ESCROW-CHECKIN-$bookingId',
      isGpsTrackingActive: true,
    );
  }

  @override
  Future<CompanionBooking> checkInWithOtp({
    required String bookingId,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Validates OTP (7492 is default)
    if (otp == '7492') {
      return CompanionBooking(
        id: bookingId,
        companionId: 'comp_1',
        companionName: 'Advika Sengupta',
        companionAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        scheduledDateTime: DateTime.now(),
        durationHours: 2,
        eventCategory: 'Gallery & Arts',
        publicVenueName: 'Kala Ghoda Art Pavilion',
        publicVenueAddress: 'Kala Ghoda, Fort, Mumbai',
        venueLat: 18.9298,
        venueLng: 72.8331,
        totalAmount: 1700.0,
        escrowStatus: EscrowStatus.heldInEscrow,
        bookingState: BookingState.inProgress,
        checkInOtp: otp,
        qrCodeToken: 'DATE2-CHECKED-IN-$bookingId',
        isGpsTrackingActive: true,
        checkInTime: DateTime.now(),
      );
    } else {
      throw Exception('Invalid OTP. Please check with your companion.');
    }
  }

  @override
  Future<void> triggerEmergencySos({
    required String bookingId,
    required double currentLat,
    required double currentLng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Stub for POST /v1/bookings/{id}/sos
  }
}
