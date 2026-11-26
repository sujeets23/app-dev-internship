import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/constants/onboarding_options.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/widgets/primary_button.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';

/// Feature 4: Personal Information Screen
/// Unifies Personal Profile details, strict 4-option Sex selector with visibility toggle,
/// matching preferences (same 4 options), 8-category interest manager (min 3),
/// real-time profile completion meter, and full local persistence.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  String? _selectedSex;
  bool _isSexVisible = true;
  late List<String> _selectedInterests;
  late List<String> _matchSexPreferences;
  late int _minAge;
  late int _maxAge;
  late int _maxDistance;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(onboardingProvider).profile;
    _nameController = TextEditingController(
      text: profile.firstName.isNotEmpty ? profile.firstName : 'Alex',
    );
    _bioController = TextEditingController(
      text: profile.bio.isNotEmpty
          ? profile.bio
          : 'Coffee enthusiast, indie music collector & weekend pottery regular.',
    );
    _selectedSex = profile.sex ?? 'Trans';
    _isSexVisible = profile.isSexVisible;
    _selectedInterests = List<String>.from(
      profile.interests.isNotEmpty
          ? profile.interests
          : ['Coffee Roasts', 'Indie Rock', 'Film Photography'],
    );
    _matchSexPreferences = List<String>.from(
      profile.matchSexPreferences.isNotEmpty
          ? profile.matchSexPreferences
          : ['Female', 'Trans', 'Others'],
    );
    _minAge = profile.minAgePreference;
    _maxAge = profile.maxAgePreference;
    _maxDistance = profile.maxDistanceKm;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  double get _completionScore {
    double score = 0.0;
    if (_nameController.text.trim().isNotEmpty) score += 0.20;
    if (_bioController.text.trim().isNotEmpty) score += 0.20;
    if (_selectedSex != null && _selectedSex!.isNotEmpty) score += 0.20;
    if (_selectedInterests.length >= 3) score += 0.20;
    if (_matchSexPreferences.isNotEmpty) score += 0.20;
    return score.clamp(0.0, 1.0);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSex == null || _selectedSex!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your sex (strictly Male, Female, Trans, or Others).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 3 interests to proceed.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_matchSexPreferences.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one matching sex preference.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentProfile = ref.read(onboardingProvider).profile;
    final updated = currentProfile.copyWith(
      firstName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      sex: _selectedSex,
      isSexVisible: _isSexVisible,
      interests: _selectedInterests,
      matchSexPreferences: _matchSexPreferences,
      minAgePreference: _minAge,
      maxAgePreference: _maxAge,
      maxDistanceKm: _maxDistance,
    );

    ref.read(onboardingProvider.notifier).updateFullProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Personal Information saved successfully!'),
          ],
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.encreElevated
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final score = _completionScore;
    final scorePercent = (score * 100).round();

    final categories = ['All', ...OnboardingOptions.interestCategories.keys];

    // Filtered interests by selected category
    final Map<String, List<String>> displayedGrouped = {};
    for (final entry in OnboardingOptions.interestCategories.entries) {
      if (_selectedCategory != 'All' && entry.key != _selectedCategory) {
        continue;
      }
      displayedGrouped[entry.key] = entry.value;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Personal Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Completion Meter
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: AppColors.glanceableCyanDeep,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PROFILE COMPLETION',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scorePercent >= 80
                                  ? (isDark
                                      ? AppColors.glanceableCyan
                                          .withValues(alpha: 0.18)
                                      : AppColors.glacierLight)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$scorePercent%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: scorePercent >= 80
                                    ? AppColors.glanceableCyanDeep
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: score,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.glanceableCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 1: PERSONAL DETAILS
                Text(
                  'PROFILE DETAILS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameController,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 280,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Biography',
                    hintText: 'Share a little about yourself...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please write a short bio';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 20),

                // SECTION 2: SEX SELECTOR (Strictly 4 options)
                Text(
                  'SEX (4-OPTION SPECIFICATION)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Restricted strictly to Male, Female, Trans, and Others as specified.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: OnboardingOptions.sexOptions.map((sex) {
                    final isSelected = _selectedSex == sex;
                    return ChoiceChip(
                      label: Text(sex),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedSex = sex);
                        }
                      },
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.encreDeep
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                      ),
                      selectedColor: AppColors.glanceableCyan,
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.glanceableCyan
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.border),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Visibility Toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isSexVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Show sex on profile',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Visible on your discovery card',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isSexVisible,
                        activeColor: AppColors.glanceableCyanDeep,
                        activeTrackColor: AppColors.glanceableCyan,
                        onChanged: (val) {
                          setState(() => _isSexVisible = val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // SECTION 3: MATCHING PREFERENCES (Exact same 4 options)
                Text(
                  'MATCHING PREFERENCES',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Specify who you want to be matched with (Male, Female, Trans, Others).',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: OnboardingOptions.sexOptions.map((sex) {
                    final isSelected = _matchSexPreferences.contains(sex);
                    return FilterChip(
                      label: Text(sex),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _matchSexPreferences.add(sex);
                          } else {
                            _matchSexPreferences.remove(sex);
                          }
                        });
                      },
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.encreDeep
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                      ),
                      selectedColor: AppColors.glanceableCyan,
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.glanceableCyan
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.border),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // SECTION 4: WHAT DO THEY LIKE (8 Categories, Min 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WHAT DO YOU LIKE?',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedInterests.length >= 3
                            ? AppColors.success.withValues(alpha: 0.15)
                            : AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_selectedInterests.length}/3 min',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _selectedInterests.length >= 3
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose interests from the categories below to highlight shared passions.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Category filter pills
                SizedBox(
                  height: 36,
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
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.encreDeep
                              : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                        ),
                        selectedColor: AppColors.glanceableCyan,
                        backgroundColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.glanceableCyan
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.border),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Grouped Interest Chips
                ...displayedGrouped.entries.map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.key.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: group.value.map((interest) {
                            final isSelected =
                                _selectedInterests.contains(interest);
                            return FilterChip(
                              label: Text(interest),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedInterests.add(interest);
                                  } else {
                                    _selectedInterests.remove(interest);
                                  }
                                });
                              },
                              labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.encreDeep
                                    : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary),
                              ),
                              selectedColor: AppColors.glanceableCyan,
                              backgroundColor: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.glanceableCyan
                                      : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.border),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Save Button
                PrimaryButton(
                  label: 'Save Profile Changes',
                  icon: Icons.check_circle_rounded,
                  onPressed: _save,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
