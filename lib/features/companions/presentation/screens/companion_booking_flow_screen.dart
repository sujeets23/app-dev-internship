import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../../domain/models/companion_model.dart';
import '../../domain/models/companion_booking.dart';
import '../providers/companion_provider.dart';

class CompanionBookingFlowScreen extends ConsumerStatefulWidget {
  final CompanionModel companion;

  const CompanionBookingFlowScreen({super.key, required this.companion});

  @override
  ConsumerState<CompanionBookingFlowScreen> createState() =>
      _CompanionBookingFlowScreenState();
}

class _CompanionBookingFlowScreenState
    extends ConsumerState<CompanionBookingFlowScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  int _durationHours = 2;
  String _selectedCategory = 'Gallery & Arts';
  String _selectedVenue = 'Kala Ghoda Art Pavilion, Fort, Mumbai';
  double _venueLat = 18.9298;
  double _venueLng = 72.8331;
  bool _isSubmitting = false;
  CompanionBooking? _confirmedBooking;
  final TextEditingController _otpCheckInController = TextEditingController();

  final List<String> _eventCategories = [
    'Gallery & Arts',
    'Tech Conference',
    'Queer Social',
    'Theater & Arts',
    'Formal Dinner',
    'City Tour',
  ];

  final List<Map<String, dynamic>> _publicVenues = [
    {
      'name': 'Kala Ghoda Art Pavilion, Fort',
      'lat': 18.9298,
      'lng': 72.8331,
      'type': 'Cultural & Art District',
    },
    {
      'name': 'National Gallery of Modern Art, Colaba',
      'lat': 18.9265,
      'lng': 72.8322,
      'type': 'Public Museum',
    },
    {
      'name': 'Subko Specialty Coffee Roasters, Bandra',
      'lat': 19.0596,
      'lng': 72.8295,
      'type': 'Queer-friendly Partner Cafe',
    },
    {
      'name': 'Bandra Bandstand Promenade',
      'lat': 19.0433,
      'lng': 72.8197,
      'type': 'Open Public Promenade',
    },
  ];

  @override
  void dispose() {
    _otpCheckInController.dispose();
    super.dispose();
  }

  double get _totalEscrowAmount => _durationHours * widget.companion.hourlyRate;

  Future<void> _submitBooking() async {
    setState(() => _isSubmitting = true);
    try {
      final service = ref.read(companionServiceProvider);
      final scheduled = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final booking = await service.createBooking(
        companionId: widget.companion.id,
        dateTime: scheduled,
        durationHours: _durationHours,
        eventCategory: _selectedCategory,
        venueName: _selectedVenue,
        venueAddress: _selectedVenue,
        venueLat: _venueLat,
        venueLng: _venueLng,
        hourlyRate: widget.companion.hourlyRate,
      );

      ref.read(activeBookingProvider.notifier).setBooking(booking);
      setState(() {
        _confirmedBooking = booking;
        _isSubmitting = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmedBooking != null) {
      return _buildConfirmationScreen(_confirmedBooking!);
    }

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
          'Book Safety Escrow',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Companion mini-header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(widget.companion.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.companion.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹${widget.companion.hourlyRate.toInt()}/hr • Escrow Protected',
                          style: const TextStyle(color: AppColors.neonLime, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 1: Event Category
            _buildSectionHeader('1. EVENT CATEGORY (PUBLIC EVENTS ONLY)'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceDark,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: _eventCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Step 2: Date & Time Picker
            _buildSectionHeader('2. DATE & START TIME'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.softPink, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) setState(() => _selectedTime = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColors.neonLime, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Step 3: Duration Selection
            _buildSectionHeader('3. BOOKING DURATION: $_durationHours HOURS'),
            const SizedBox(height: 4),
            Slider(
              value: _durationHours.toDouble(),
              min: 1,
              max: 6,
              divisions: 5,
              activeColor: AppColors.neonLime,
              inactiveColor: Colors.white24,
              label: '$_durationHours Hours',
              onChanged: (val) => setState(() => _durationHours = val.toInt()),
            ),

            const SizedBox(height: 16),

            // Step 4: Public Venue Selection with Map Preview
            _buildSectionHeader('4. PUBLIC VENUE SELECTION'),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1B2230),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.4)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: AppColors.neonLime, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          _selectedVenue,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        const Text('GPS Geofence Verified Public Space', style: TextStyle(color: AppColors.softPink, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVenue,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceDark,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  items: _publicVenues.map((v) {
                    return DropdownMenuItem<String>(
                      value: v['name'] as String,
                      child: Text(v['name'] as String),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final item = _publicVenues.firstWhere((v) => v['name'] == val);
                      setState(() {
                        _selectedVenue = val;
                        _venueLat = item['lat'];
                        _venueLng = item['lng'];
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Step 5: Escrow Payment Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.electricViolet.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, color: AppColors.neonLime, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'SAFETY ESCROW BREAKDOWN',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neonLime,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rate (₹${widget.companion.hourlyRate.toInt()} × $_durationHours hrs)', style: const TextStyle(color: Colors.white70)),
                      Text('₹${_totalEscrowAmount.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Safety Operations & GPS Escrow Fee', style: TextStyle(color: Colors.white70)),
                      Text('₹0 (Waived)', style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Held in Escrow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        '₹${_totalEscrowAmount.toInt()}',
                        style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '🛡️ Payment is safely locked in Date² Escrow. Funds are only released to the companion AFTER the event completes successfully.',
                    style: TextStyle(color: AppColors.textMutedDark, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricViolet,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSubmitting ? null : _submitBooking,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Lock Escrow & Confirm Booking (₹${_totalEscrowAmount.toInt()})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationScreen(CompanionBooking booking) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text('Booking Confirmed', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.neonLime.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: AppColors.neonLime, size: 54),
            ),
            const SizedBox(height: 16),
            Text(
              'Escrow Locked & Booking Confirmed!',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking ID: ${booking.id}',
              style: const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // Check-in QR & OTP Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonLime, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text(
                    'COMPANION CHECK-IN PASS',
                    style: TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Simulated QR code
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.qr_code_2, size: 120, color: Colors.black),
                  ),
                  const SizedBox(height: 14),
                  const Text('Check-in 4-Digit OTP', style: TextStyle(color: AppColors.textMutedDark, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.softPink),
                    ),
                    child: Text(
                      booking.checkInOtp,
                      style: const TextStyle(
                        color: AppColors.softPink,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Present this OTP to your companion upon arrival at the public venue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Simulate Companion Check-In Action
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Simulate Companion Check-in (OTP 7492)', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                try {
                  await ref.read(activeBookingProvider.notifier).checkIn('7492');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Check-in verified! Live GPS Tracking & Safety HUD is now active.'),
                        backgroundColor: AppColors.electricViolet,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.bodySmall.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.neonLime,
        letterSpacing: 1.1,
      ),
    );
  }
}
