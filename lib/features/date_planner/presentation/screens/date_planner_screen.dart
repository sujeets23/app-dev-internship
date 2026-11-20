import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../providers/date_planner_provider.dart';
import 'itinerary_detail_screen.dart';

class DatePlannerScreen extends ConsumerStatefulWidget {
  const DatePlannerScreen({super.key});

  @override
  ConsumerState<DatePlannerScreen> createState() => _DatePlannerScreenState();
}

class _DatePlannerScreenState extends ConsumerState<DatePlannerScreen> {
  final List<String> _neighborhoods = [
    'Bandra West, Mumbai',
    'Colaba & Fort, Mumbai',
    'Indiranagar, Bengaluru',
    'Koramangala, Bengaluru',
    'Hauz Khas, New Delhi',
    'Koregaon Park, Pune',
  ];

  final List<String> _vibes = [
    'Romantic',
    'Casual',
    'Adventure',
    'Foodie',
    'Relaxed',
  ];

  final List<String> _dietaryOptions = [
    'Any',
    'Vegetarian',
    'Vegan',
    'Halal',
    'Jain',
  ];

  @override
  Widget build(BuildContext context) {
    final inputs = ref.watch(datePlannerInputsProvider);
    final planState = ref.watch(datePlanStateProvider);
    final isLoading = planState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Text(
          'AI Date Planner',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Planner Intro Hero Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.electricViolet, Color(0xFF6E28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.neonLime, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Curate Your Perfect Date',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'AI customizes chronological stops within your exact budget, highlighting queer-friendly partner discounts.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 1. Budget Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MAX BUDGET LIMIT',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonLime,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  '₹${inputs.budget.toInt()}',
                  style: const TextStyle(
                    color: AppColors.neonLime,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Slider(
              value: inputs.budget,
              min: 500,
              max: 5000,
              divisions: 45,
              activeColor: AppColors.neonLime,
              inactiveColor: Colors.white24,
              onChanged: (val) {
                ref.read(datePlannerInputsProvider.notifier).setBudget(val);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('₹500', style: TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
                Text('₹2,500', style: TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
                Text('₹5,000', style: TextStyle(color: AppColors.textMutedDark, fontSize: 11)),
              ],
            ),

            const SizedBox(height: 24),

            // 2. Neighborhood Selector
            Text(
              'SELECT NEIGHBORHOOD',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neonLime,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: inputs.neighborhood,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceDark,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: _neighborhoods.map((n) {
                    return DropdownMenuItem(value: n, child: Text(n));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(datePlannerInputsProvider.notifier).setNeighborhood(val);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Date Vibe Selection
            Text(
              'DATE VIBE',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neonLime,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _vibes.map((vibe) {
                final isSelected = inputs.vibe == vibe;
                return ChoiceChip(
                  label: Text(vibe),
                  selected: isSelected,
                  selectedColor: AppColors.electricViolet,
                  backgroundColor: AppColors.surfaceDark,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMutedDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    ref.read(datePlannerInputsProvider.notifier).setVibe(vibe);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 4. Dietary Preferences
            Text(
              'DIETARY PREFERENCES',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neonLime,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dietaryOptions.map((diet) {
                final isSelected = inputs.dietary == diet;
                return ChoiceChip(
                  label: Text(diet),
                  selected: isSelected,
                  selectedColor: AppColors.softPink,
                  backgroundColor: AppColors.surfaceDark,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textMutedDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    ref.read(datePlannerInputsProvider.notifier).setDietary(diet);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 36),

            // Generate Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricViolet,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      await ref.read(datePlanStateProvider.notifier).generate(
                            budget: inputs.budget,
                            neighborhood: inputs.neighborhood,
                            vibe: inputs.vibe,
                            dietary: inputs.dietary,
                          );

                      final plan = ref.read(datePlanStateProvider).value;
                      if (plan != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItineraryDetailScreen(plan: plan),
                          ),
                        );
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, color: AppColors.neonLime),
                        SizedBox(width: 8),
                        Text(
                          'Generate AI Date Itinerary',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
            ),

            if (planState.value != null && !isLoading) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.neonLime,
                  side: const BorderSide(color: AppColors.neonLime),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItineraryDetailScreen(plan: planState.value!),
                    ),
                  );
                },
                child: const Text('View Current Generated Itinerary'),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
