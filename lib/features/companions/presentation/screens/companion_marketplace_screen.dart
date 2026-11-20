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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(
          'Companion Escrow',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.neonLime),
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by companion, event, or skill...',
                hintStyle: const TextStyle(color: AppColors.textMutedDark),
                prefixIcon: const Icon(Icons.search, color: AppColors.neonLime),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
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
                  selectedColor: AppColors.electricViolet,
                  backgroundColor: AppColors.surfaceDark,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMutedDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: AppColors.neonLime, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Platonic & Safety Escrow Protected',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Background-checked companions. Funds held safely in escrow until completion.',
                        style: TextStyle(color: AppColors.textMutedDark, fontSize: 11),
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
                  return const Center(
                    child: Text(
                      'No companions found matching criteria',
                      style: TextStyle(color: AppColors.textMutedDark),
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
                child: CircularProgressIndicator(color: AppColors.electricViolet),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: AppColors.neonLime, size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          companion.tagLine,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMutedDark,
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
                              style: const TextStyle(
                                color: Colors.white70,
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
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(color: AppColors.softPink, fontSize: 11),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hourly Escrow Rate',
                        style: TextStyle(color: AppColors.textMutedDark, fontSize: 11),
                      ),
                      Text(
                        '₹${companion.hourlyRate.toInt()} / hr',
                        style: const TextStyle(
                          color: AppColors.neonLime,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompanionDetailScreen(companion: companion),
                        ),
                      );
                    },
                    child: const Text('View & Book'),
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

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
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
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Max Hourly Rate: ₹${selectedRate.toInt()}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Slider(
                    value: selectedRate,
                    min: 500,
                    max: 3000,
                    divisions: 25,
                    activeColor: AppColors.neonLime,
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      setSheetState(() => selectedRate = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ref.read(companionFilterProvider.notifier).updateMaxRate(selectedRate);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply Filters'),
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
