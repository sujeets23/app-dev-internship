import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../providers/date_planner_provider.dart';
import 'itinerary_detail_screen.dart';

class DatePlannerScreen extends ConsumerStatefulWidget {
  final String? targetConversationId;
  final String? matchName;

  const DatePlannerScreen({
    super.key,
    this.targetConversationId,
    this.matchName,
  });

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

    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final mutedTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final accent = AppColors.adaptiveAccent(isDark);

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
          widget.matchName != null
              ? 'Date Planner • ${widget.matchName}'
              : 'AI Date Planner',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Planner Intro Hero Banner (Glanceable Glacier Card)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: isDark ? null : AppColors.glacierPrismGradient,
                color: isDark ? AppColors.encreElevated : null,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.glacierBorder,
                  width: 1.1,
                ),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: accent, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Curate Your Perfect Date',
                          style: AppTypography.headlineMedium.copyWith(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI customizes chronological stops within your exact budget, highlighting queer-friendly partner discounts.',
                          style: TextStyle(color: mutedTextColor, fontSize: 12),
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
                    color: accent,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '₹${inputs.budget.toInt()}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: accent,
                thumbColor: isDark ? AppColors.accentTeal : AppColors.primary,
                inactiveTrackColor: AppColors.adaptiveBorder(isDark),
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
                color: accent,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.adaptiveBorder(isDark),
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
                color: accent,
                letterSpacing: 1.0,
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
                  selectedColor:
                      isDark ? AppColors.accent : AppColors.glacierLight,
                  backgroundColor: cardBg,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (isDark ? AppColors.encreDeep : AppColors.glacierInk)
                        : textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? accent
                        : AppColors.adaptiveBorder(isDark),
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
                color: accent,
                letterSpacing: 1.0,
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
                  selectedColor:
                      isDark ? AppColors.accent : AppColors.primary,
                  backgroundColor: cardBg,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.adaptiveOnAccent(isDark)
                        : textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? accent
                        : AppColors.adaptiveBorder(isDark),
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
                  backgroundColor: accent,
                  foregroundColor: AppColors.adaptiveOnAccent(isDark),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
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
                              builder: (_) => ItineraryDetailScreen(
                                plan: plan,
                                targetConversationId: widget.targetConversationId,
                                matchName: widget.matchName,
                              ),
                            ),
                          );
                        }
                      },
                icon: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.adaptiveOnAccent(isDark),
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.auto_awesome, color: AppColors.adaptiveOnAccent(isDark)),
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
