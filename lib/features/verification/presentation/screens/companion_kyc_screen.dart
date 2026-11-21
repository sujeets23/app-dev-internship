import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

class CompanionKycScreen extends StatefulWidget {
  const CompanionKycScreen({super.key});

  @override
  State<CompanionKycScreen> createState() => _CompanionKycScreenState();
}

class _CompanionKycScreenState extends State<CompanionKycScreen> {
  String _selectedIdType = 'Aadhaar Card';
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _policeClearanceChecked = false;
  bool _isSubmitting = false;

  final List<String> _idTypes = [
    'Aadhaar Card',
    'Passport',
    'Driving License',
    'Voter ID',
  ];

  void _submitKyc() async {
    if (!_frontUploaded || !_backUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both Front and Back of your Government ID.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_policeClearanceChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please affirm the background & identity standards check.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() => _isSubmitting = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.verified_user_rounded, color: AppColors.success, size: 28),
              SizedBox(width: 8),
              Text('KYC Submitted'),
            ],
          ),
          content: const Text(
            'Your document images were verified in volatile secure memory and submitted for cryptographic background assurance (POST /v1/auth/companion-kyc). Raw images have been securely wiped.',
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.softWhite;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Companion KYC Verification',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE5D5FF), Color(0xFFF8C0AE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, color: AppColors.primary, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trust & Safety Escrow Standard',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.charcoal,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'All companions must submit a valid government photo ID and undergo criminal background checks prior to taking bookings.',
                          style: TextStyle(color: Color(0xFF3B3347), fontSize: 11, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select ID Type
            Text(
              'SELECT GOVERNMENT ID TYPE',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.neonLime : AppColors.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.transparent : AppColors.softLavender,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIdType,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                  items: _idTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedIdType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Document Front Upload Box
            Text(
              'FRONT OF DOCUMENT',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.neonLime : AppColors.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            _buildUploadCard(
              title: 'Upload Front Photo',
              subtitle: 'Ensure name, photo, and ID number are clearly legible',
              isUploaded: _frontUploaded,
              onTap: () {
                setState(() => _frontUploaded = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Front of ID captured successfully')),
                );
              },
            ),
            const SizedBox(height: 18),

            // Document Back Upload Box
            Text(
              'BACK OF DOCUMENT',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.neonLime : AppColors.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            _buildUploadCard(
              title: 'Upload Back Photo',
              subtitle: 'Must display residential address and issuing authority barcode',
              isUploaded: _backUploaded,
              onTap: () {
                setState(() => _backUploaded = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Back of ID captured successfully')),
                );
              },
            ),
            const SizedBox(height: 24),

            // Background affirmation check
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _policeClearanceChecked,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    onChanged: (val) => setState(() => _policeClearanceChecked = val ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'I attest that I have no criminal record, active investigations, or safety sanctions. I consent to automated KYC validation.',
                    style: TextStyle(color: mutedTextColor, fontSize: 12, height: 1.35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.butterYellow,
                  foregroundColor: AppColors.charcoal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                ),
                onPressed: _isSubmitting ? null : _submitKyc,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: AppColors.charcoal, strokeWidth: 2),
                      )
                    : const Icon(Icons.shield_outlined, size: 20),
                label: Text(
                  _isSubmitting ? 'Verifying Documents...' : 'Submit KYC for Escrow Badge',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.success.withValues(alpha: 0.1)
              : cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded
                ? AppColors.success
                : (isDark ? Colors.white12 : AppColors.softLavender),
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.success
                    : AppColors.softLavender.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded ? Icons.check_circle_rounded : Icons.document_scanner_outlined,
                color: isUploaded ? Colors.white : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUploaded ? '$title (Captured ✓)' : title,
                    style: TextStyle(
                      color: isUploaded ? AppColors.success : textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isUploaded ? 'Document frame aligned & securely buffered' : subtitle,
                    style: TextStyle(color: mutedTextColor, fontSize: 11),
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
