import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../../domain/models/companion_model.dart';
import '../providers/companion_provider.dart';
import 'companion_detail_screen.dart';

class CompanionMarketplaceScreen extends ConsumerStatefulWidget {
  const CompanionMarketplaceScreen({super.key});

  @override
  ConsumerState<CompanionMarketplaceScreen> createState() =>
      _CompanionMarketplaceScreenState();
}

class _CompanionMarketplaceScreenState
    extends ConsumerState<CompanionMarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Gallery & Arts',
    'Tech Conference',
    'Queer Social',
    'Theater',
    'Formal Dinner',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companionsAsync = ref.watch(companionsListProvider);
    final filter = ref.watch(companionFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          'Companion Escrow',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: isDark ? AppColors.neonLime : AppColors.primary),
            tooltip: 'Filter Options',
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(companionFilterProvider.notifier).updateSearch(val);
              },
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search by companion, event, or skill...',
                hintStyle: TextStyle(color: mutedTextColor),
                prefixIcon: Icon(Icons.search, color: isDark ? AppColors.neonLime : AppColors.primary),
                filled: true,
                fillColor: cardBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.transparent : AppColors.softLavender,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.accent : AppColors.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Event Categories Horizontal List
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = filter.category == cat;

                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.butterYellow,
                  backgroundColor: cardBg,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.charcoal : textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.butterYellow
                        : (isDark ? Colors.white12 : AppColors.softLavender),
                  ),
                  onSelected: (_) {
                    ref.read(companionFilterProvider.notifier).updateCategory(cat);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Safety Escrow Explainer Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.softLavender.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.neonLime.withValues(alpha: 0.3) : AppColors.softLavender,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: isDark ? AppColors.neonLime : AppColors.primary,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Platonic & Safety Escrow Protected',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Background-checked companions. Funds held safely in escrow until completion.',
                        style: TextStyle(color: mutedTextColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Companions List
          Expanded(
            child: companionsAsync.when(
              data: (companions) {
                if (companions.isEmpty) {
                  return Center(
                    child: Text(
                      'No companions found matching criteria',
                      style: TextStyle(color: mutedTextColor),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: companions.length,
                  itemBuilder: (context, index) {
                    final companion = companions[index];
                    return _buildCompanionCard(context, companion);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionCard(BuildContext context, CompanionModel companion) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.charcoal;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.softLavender,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softLavender.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompanionDetailScreen(companion: companion),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      companion.avatarUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${companion.name}, ${companion.age}',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: AppColors.primary, size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          companion.tagLine,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: mutedTextColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              '${companion.rating} (${companion.reviewCount} reviews)',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Specialties Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: companion.specialties.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceElevatedDark : AppColors.softLavender.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        color: isDark ? AppColors.softPink : AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Divider(color: isDark ? Colors.white10 : AppColors.softLavender.withValues(alpha: 0.6)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hourly Escrow Rate',
                        style: TextStyle(color: mutedTextColor, fontSize: 11),
                      ),
                      Text(
                        '₹${companion.hourlyRate.toInt()} / hr',
                        style: TextStyle(
                          color: isDark ? AppColors.neonLime : AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.butterYellow,
                      foregroundColor: AppColors.charcoal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompanionDetailScreen(companion: companion),
                        ),
                      );
                    },
                    child: const Text('View & Book', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final filter = ref.read(companionFilterProvider);
    double selectedRate = filter.maxRate;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Companions',
                    style: AppTypography.headlineMedium.copyWith(
                      color: isDark ? Colors.white : AppColors.charcoal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Max Hourly Rate: ₹${selectedRate.toInt()}',
                    style: TextStyle(color: isDark ? Colors.white70 : AppColors.charcoal),
                  ),
                  Slider(
                    value: selectedRate,
                    min: 500,
                    max: 3000,
                    divisions: 25,
                    activeColor: AppColors.blushPink,
                    inactiveColor: AppColors.softLavender,
                    onChanged: (val) {
                      setSheetState(() => selectedRate = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.butterYellow,
                      foregroundColor: AppColors.charcoal,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ref.read(companionFilterProvider.notifier).updateMaxRate(selectedRate);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
