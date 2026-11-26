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
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmedBooking != null) {
      return _buildConfirmationScreen(_confirmedBooking!);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final insetBg = isDark ? AppColors.surfaceElevatedDark : AppColors.glacierLight;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final glacierBorder = isDark ? AppColors.borderDark : AppColors.glacierBorder;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final accent = AppColors.adaptiveAccent(isDark);
    final onAccent = AppColors.adaptiveOnAccent(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Safety Escrow',
          style: AppTypography.headlineMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
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
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
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
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹${widget.companion.hourlyRate.toInt()}/hr • Escrow Protected',
                          style: TextStyle(
                            color: isDark ? AppColors.accent : AppColors.accentTeal,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step 1: Event Category
            _buildSectionHeader(context, '1. EVENT CATEGORY (PUBLIC EVENTS ONLY)'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  style: TextStyle(color: textPrimary, fontSize: 14),
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
            _buildSectionHeader(context, '2. DATE & START TIME'),
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
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: accent, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: TextStyle(color: textPrimary, fontSize: 13),
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
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: accent, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime.format(context),
                            style: TextStyle(color: textPrimary, fontSize: 13),
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
            _buildSectionHeader(context, '3. BOOKING DURATION: $_durationHours HOURS'),
            const SizedBox(height: 4),
            Slider(
              value: _durationHours.toDouble(),
              min: 1,
              max: 6,
              divisions: 5,
              activeColor: accent,
              inactiveColor: border,
              label: '$_durationHours Hours',
              onChanged: (val) => setState(() => _durationHours = val.toInt()),
            ),

            const SizedBox(height: 16),

            // Step 4: Public Venue Selection with Map Preview
            _buildSectionHeader(context, '4. PUBLIC VENUE SELECTION'),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: insetBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: glacierBorder),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: accent, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          _selectedVenue,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'GPS Geofence Verified Public Space',
                          style: TextStyle(
                            color: isDark ? AppColors.accent : AppColors.accentTeal,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedVenue,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  style: TextStyle(color: textPrimary, fontSize: 13),
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
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: glacierBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline, color: accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'SAFETY ESCROW BREAKDOWN',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.accent : textSecondary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rate (₹${widget.companion.hourlyRate.toInt()} × $_durationHours hrs)', style: TextStyle(color: textSecondary)),
                      Text('₹${_totalEscrowAmount.toInt()}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Safety Operations & GPS Escrow Fee', style: TextStyle(color: textSecondary)),
                      const Text('₹0 (Waived)', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Divider(color: border, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Held in Escrow', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(
                        '₹${_totalEscrowAmount.toInt()}',
                        style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🛡️ Payment is safely locked in Date² Escrow. Funds are only released to the companion AFTER the event completes successfully.',
                    style: TextStyle(color: textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isSubmitting ? null : _submitBooking,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: onAccent)
                  : Text(
                      'Lock Escrow & Confirm Booking (₹${_totalEscrowAmount.toInt()})',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationScreen(CompanionBooking booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final insetBg = isDark ? AppColors.backgroundDark : AppColors.glacierLight;
    final glacierBorder = isDark ? AppColors.accent : AppColors.glacierBorder;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final accent = AppColors.adaptiveAccent(isDark);
    final onAccent = AppColors.adaptiveOnAccent(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: Text('Booking Confirmed', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
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
                color: isDark ? AppColors.success.withValues(alpha: 0.15) : AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: AppColors.success, size: 54),
            ),
            const SizedBox(height: 16),
            Text(
              'Escrow Locked & Booking Confirmed!',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking ID: ${booking.id}',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // Check-in QR & OTP Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: glacierBorder, width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    'COMPANION CHECK-IN PASS',
                    style: TextStyle(
                      color: isDark ? AppColors.accent : AppColors.primary,
                      fontWeight: FontWeight.w700,
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
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.qr_code_2, size: 120, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  Text('Check-in 4-Digit OTP', style: TextStyle(color: textMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: insetBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: glacierBorder),
                    ),
                    child: Text(
                      booking.checkInOtp,
                      style: TextStyle(
                        color: accent,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Present this OTP to your companion upon arrival at the public venue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Simulate Companion Check-In Action
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Simulate Companion Check-in (OTP 7492)', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () async {
                try {
                  await ref.read(activeBookingProvider.notifier).checkIn('7492');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Check-in verified! Live GPS Tracking & Safety HUD is now active.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: AppTypography.bodySmall.copyWith(
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.accent : AppColors.textSecondary,
        letterSpacing: 1.1,
      ),
    );
  }
}
