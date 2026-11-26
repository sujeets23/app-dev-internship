import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/onboarding_options.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// Screen 5: What Do They Like (Categorized Interest Selection)
/// Organizes interests across 8 categories with a minimum requirement of 3 selections.
class InterestsSelectionScreen extends ConsumerStatefulWidget {
  const InterestsSelectionScreen({super.key});

  @override
  ConsumerState<InterestsSelectionScreen> createState() =>
      _InterestsSelectionScreenState();
}

class _InterestsSelectionScreenState
    extends ConsumerState<InterestsSelectionScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final selectedInterests = state.profile.interests;
    final errors = state.errors;

    final categories = ['All', ...OnboardingOptions.interestCategories.keys];
    final meetsMinimum = selectedInterests.length >= 3;

    // Filter interests based on category and search query
    final Map<String, List<String>> displayedGrouped = {};
    for (final entry in OnboardingOptions.interestCategories.entries) {
      if (_selectedCategory != 'All' && entry.key != _selectedCategory) {
        continue;
      }
      final filteredList = entry.value.where((interest) {
        if (_searchQuery.isEmpty) return true;
        return interest.toLowerCase().contains(_searchQuery);
      }).toList();

      if (filteredList.isNotEmpty) {
        displayedGrouped[entry.key] = filteredList;
      }
    }

    return OnboardingStepScaffold(
      currentStep: 5,
      totalSteps: 6,
      title: 'What do you like?',
      subtitle:
          'Select at least 3 interests to help our discovery engine find like-minded matches who share your lifestyle and passions.',
      nextButtonLabel:
          state.editingFromReview ? 'Update Interests' : 'Continue',
      onBack: () => notifier.previousStep(),
      onNext: () {
        if (selectedInterests.length < 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Please select at least 3 interests to continue.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }
        notifier.nextStep();
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Counter Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: meetsMinimum
                  ? (isDark
                      ? AppColors.glanceableCyan.withValues(alpha: 0.15)
                      : AppColors.glacierLight)
                  : (isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: meetsMinimum
                    ? AppColors.glanceableCyan
                    : (isDark ? AppColors.borderDark : AppColors.border),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  meetsMinimum
                      ? Icons.check_circle_rounded
                      : Icons.lightbulb_outline_rounded,
                  color: meetsMinimum
                      ? AppColors.glanceableCyanDeep
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meetsMinimum
                            ? '${selectedInterests.length} interests selected'
                            : '${selectedInterests.length} of 3 selected (minimum)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meetsMinimum
                            ? 'Great taste! You can pick more to refine recommendations.'
                            : 'Choose ${3 - selectedInterests.length} more to continue.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (errors.containsKey('interests')) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errors['interests']!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Search Field
          TextField(
            controller: _searchController,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search interests...',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiary,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.glanceableCyan,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category Pills
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.encreDeep
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  ),
                  selectedColor: AppColors.glanceableCyan,
                  backgroundColor:
                      isDark ? AppColors.surfaceDark : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.glanceableCyan
                          : (isDark ? AppColors.borderDark : AppColors.border),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Categorized Interest Chips
          if (displayedGrouped.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No matching interests found.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ] else ...[
            ...displayedGrouped.entries.map((group) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.key.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: group.value.map((interest) {
                        final isSelected =
                            selectedInterests.contains(interest);
                        return FilterChip(
                          label: Text(interest),
                          selected: isSelected,
                          onSelected: (_) {
                            notifier.toggleInterest(interest);
                          },
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.encreDeep
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          ),
                          avatar: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: AppColors.encreDeep,
                                )
                              : null,
                          selectedColor: AppColors.glanceableCyan,
                          backgroundColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.glanceableCyan
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.border),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
