import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../../domain/models/companion_model.dart';
import 'companion_booking_flow_screen.dart';

class CompanionDetailScreen extends StatelessWidget {
  final CompanionModel companion;

  const CompanionDetailScreen({super.key, required this.companion});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final accent = AppColors.adaptiveAccent(isDark);
    final onAccent = AppColors.adaptiveOnAccent(isDark);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // App Bar with Photo Hero
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: scaffoldBg,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.6),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    companion.avatarUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          scaffoldBg.withValues(alpha: 0.85),
                          scaffoldBg,
                        ],
                        stops: const [0.55, 0.88, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Badges
                  Row(
                    children: [
                      Text(
                        '${companion.name}, ${companion.age}',
                        style: AppTypography.headlineMedium.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: AppColors.accentTeal, size: 20),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    companion.tagLine,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Escrow & Rating Stat Cards
                  Row(
                    children: [
                      _buildStatCard(
                        context: context,
                        icon: Icons.star,
                        iconColor: AppColors.warning,
                        title: '${companion.rating}',
                        subtitle: '${companion.reviewCount} Reviews',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context: context,
                        icon: Icons.security,
                        iconColor: AppColors.accentTeal,
                        title: '100% Escrow',
                        subtitle: 'Safe Payments',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context: context,
                        icon: Icons.verified_user,
                        iconColor: accent,
                        title: 'ID Verified',
                        subtitle: 'Govt & Biometric',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Languages
                  Text(
                    'SPOKEN LANGUAGES',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.accent : textSecondary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: companion.languages.map((lang) {
                      return Chip(
                        label: Text(lang),
                        backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.glacierLight,
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.glacierBorder),
                        labelStyle: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Bio
                  Text(
                    'ABOUT COMPANION',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.accent : textSecondary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    companion.bio,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Specialties
                  Text(
                    'EVENT SPECIALTIES',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.accent : textSecondary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: companion.specialties.map((spec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceElevatedDark : AppColors.glacierLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.glacierBorder,
                          ),
                        ),
                        child: Text(
                          spec,
                          style: TextStyle(
                            color: isDark ? AppColors.accent : AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Client Reviews
                  Text(
                    'VERIFIED CLIENT REVIEWS',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.accent : textSecondary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...companion.reviews.map((rev) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  rev.userName,
                                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
                                ),
                                const Spacer(),
                                const Icon(Icons.star, color: AppColors.warning, size: 14),
                                const SizedBox(width: 4),
                                Text('${rev.rating}', style: TextStyle(color: textSecondary, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(rev.comment, style: TextStyle(color: textSecondary, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(rev.date, style: TextStyle(color: textMuted, fontSize: 11)),
                          ],
                        ),
                      )),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: border)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Escrow Hourly Rate', style: TextStyle(color: textMuted, fontSize: 11)),
                  Text(
                    '₹${companion.hourlyRate.toInt()} / hr',
                    style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompanionBookingFlowScreen(companion: companion),
                    ),
                  );
                },
                child: const Text('Book Platonic Escrow', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
