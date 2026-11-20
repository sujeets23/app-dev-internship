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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App Bar with Photo Hero
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
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
                          AppColors.backgroundDark.withValues(alpha: 0.9),
                          AppColors.backgroundDark,
                        ],
                        stops: const [0.5, 0.85, 1.0],
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: AppColors.neonLime, size: 20),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    companion.tagLine,
                    style: const TextStyle(
                      color: AppColors.textMutedDark,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Escrow & Rating Stat Cards
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.star,
                        iconColor: Colors.amber,
                        title: '${companion.rating}',
                        subtitle: '${companion.reviewCount} Reviews',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.security,
                        iconColor: AppColors.neonLime,
                        title: '100% Escrow',
                        subtitle: 'Safe Payments',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.verified_user,
                        iconColor: AppColors.softPink,
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
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonLime,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: companion.languages.map((lang) {
                      return Chip(
                        label: Text(lang),
                        backgroundColor: AppColors.surfaceDark,
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Bio
                  Text(
                    'ABOUT COMPANION',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonLime,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    companion.bio,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Specialties
                  Text(
                    'EVENT SPECIALTIES',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonLime,
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
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.electricViolet.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          spec,
                          style: const TextStyle(color: AppColors.softPink, fontSize: 13),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Client Reviews
                  Text(
                    'VERIFIED CLIENT REVIEWS',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonLime,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...companion.reviews.map((rev) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  rev.userName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text('${rev.rating}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(rev.comment, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(rev.date, style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
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
          color: AppColors.surfaceDark,
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Escrow Hourly Rate', style: TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
                  Text(
                    '₹${companion.hourlyRate.toInt()} / hr',
                    style: const TextStyle(color: AppColors.neonLime, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricViolet,
                  foregroundColor: Colors.white,
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
                child: const Text('Book Platonic Escrow', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppColors.textMutedDark, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
