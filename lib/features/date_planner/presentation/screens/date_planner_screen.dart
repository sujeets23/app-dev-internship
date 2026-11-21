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
        title: Text(
          'AI Date Planner',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE5D5FF), Color(0xFFF8C0AE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.peach.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Curate Your Perfect Date',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.charcoal,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'AI customizes chronological stops within your exact budget, highlighting queer-friendly partner discounts.',
                          style: TextStyle(color: Color(0xFF3B3347), fontSize: 12),
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
                    color: isDark ? AppColors.neonLime : AppColors.primary,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  '₹${inputs.budget.toInt()}',
                  style: TextStyle(
                    color: isDark ? AppColors.neonLime : AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.blushPink,
                thumbColor: AppColors.butterYellow,
                inactiveTrackColor: AppColors.softLavender,
              ),
              child: Slider(
                value: inputs.budget,
                min: 500,
                max: 5000,
                divisions: 45,
                label: '₹${inputs.budget.toInt()}',
                onChanged: (val) {
                  ref.read(datePlannerInputsProvider.notifier).setBudget(val);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹500 (Budget-friendly)', style: TextStyle(color: mutedTextColor, fontSize: 11)),
                Text('₹5,000 (Luxury date)', style: TextStyle(color: mutedTextColor, fontSize: 11)),
              ],
            ),

            const SizedBox(height: 24),

            // 2. City / Neighborhood Selection
            Text(
              'SELECT NEIGHBORHOOD',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
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
                  value: inputs.neighborhood,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
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

            // 3. Vibe Preference Chips
            Text(
              'CHOOSE DATE VIBE',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.neonLime : AppColors.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _vibes.map((v) {
                final isSelected = inputs.vibe == v;
                return ChoiceChip(
                  label: Text(v),
                  selected: isSelected,
                  selectedColor: AppColors.butterYellow,
                  backgroundColor: cardBg,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.charcoal : textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.butterYellow
                        : (isDark ? Colors.white12 : AppColors.softLavender),
                  ),
                  onSelected: (_) {
                    ref.read(datePlannerInputsProvider.notifier).setVibe(v);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 4. Dietary Inclusivity Filter
            Text(
              'DIETARY PREFERENCE',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.neonLime : AppColors.primary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dietaryOptions.map((d) {
                final isSelected = inputs.dietary == d;
                return ChoiceChip(
                  label: Text(d),
                  selected: isSelected,
                  selectedColor: AppColors.blushPink,
                  backgroundColor: cardBg,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.blushPink
                        : (isDark ? Colors.white12 : AppColors.softLavender),
                  ),
                  onSelected: (_) {
                    ref.read(datePlannerInputsProvider.notifier).setDietary(d);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.butterYellow,
                  foregroundColor: AppColors.charcoal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
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
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: AppColors.charcoal, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, color: AppColors.charcoal),
                label: Text(
                  isLoading ? 'Generating AI Itinerary...' : 'Generate Date Plan',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
