import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/gender_identity.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/pronouns.dart';
import 'package:inclusive_dating/features/onboarding/domain/models/sexual_orientation.dart';
import 'package:inclusive_dating/features/onboarding/presentation/providers/onboarding_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _pronounsController;
  late final TextEditingController _bioController;

  late String _genderIdentity;
  late String _sexualOrientation;
  late String _connectionPreference;

  final List<String> _genders = ['Non-Binary', 'Woman', 'Man', 'Transgender', 'Genderfluid', 'Agender', 'Self-described'];
  final List<String> _orientations = ['Queer', 'Bisexual', 'Pansexual', 'Lesbian', 'Gay', 'Asexual', 'Questioning'];
  final List<String> _preferences = ['Dating & Friendships', 'Long-term Romantic', 'Casual Dating', 'Platonic Companionship'];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(onboardingProvider).profile;
    _nameController = TextEditingController(
      text: profile.firstName.isNotEmpty ? profile.firstName : 'Alex',
    );
    _ageController = TextEditingController(
      text: '${profile.age ?? 25}',
    );
    _pronounsController = TextEditingController(
      text: profile.displayPronouns != 'Not specified'
          ? profile.displayPronouns
          : 'they/them',
    );
    _bioController = TextEditingController(
      text: profile.bio.isNotEmpty
          ? profile.bio
          : 'Designer & creative thinker exploring meaningful dating & creative friendships.',
    );
    _genderIdentity = _genders.contains(profile.displayGender)
        ? profile.displayGender
        : 'Non-Binary';
    _sexualOrientation = _orientations.contains(profile.displayOrientation)
        ? profile.displayOrientation
        : 'Queer';
    _connectionPreference = profile.connectionPreferences.isNotEmpty &&
            _preferences.contains(profile.connectionPreferences.first)
        ? profile.connectionPreferences.first
        : 'Dating & Friendships';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _pronounsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final current = ref.read(onboardingProvider).profile;
    final updated = current.copyWith(
      firstName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      genderIdentity: GenderIdentity(option: _genderIdentity),
      pronouns: Pronouns(
        option: 'Custom',
        customPronouns: _pronounsController.text.trim(),
      ),
      sexualOrientation: SexualOrientation(option: _sexualOrientation),
      connectionPreferences: [_connectionPreference],
    );
    ref.read(onboardingProvider.notifier).updateFullProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated & persisted locally!'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.encreElevated
            : AppColors.primary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final hintColor =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Inclusive Profile',
          style: AppTypography.headlineMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            _buildFieldLabel('DISPLAY NAME', isDark),
            _buildTextField(_nameController, 'Your Name',
                cardBg: cardBg, textColor: textColor, hintColor: hintColor, isDark: isDark),
            const SizedBox(height: 16),

            // Age Field
            _buildFieldLabel('AGE', isDark),
            _buildTextField(_ageController, 'Your Age',
                keyboardType: TextInputType.number,
                cardBg: cardBg,
                textColor: textColor,
                hintColor: hintColor,
                isDark: isDark),
            const SizedBox(height: 16),

            // Custom Pronouns
            _buildFieldLabel('CUSTOM PRONOUNS', isDark),
            _buildTextField(_pronounsController, 'e.g. they/them, she/her, he/they',
                cardBg: cardBg, textColor: textColor, hintColor: hintColor, isDark: isDark),
            const SizedBox(height: 16),

            // Gender Identity Dropdown
            _buildFieldLabel('GENDER IDENTITY', isDark),
            _buildDropdown(
              value: _genderIdentity,
              items: _genders,
              onChanged: (val) => setState(() => _genderIdentity = val!),
              cardBg: cardBg,
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Sexual Orientation Dropdown
            _buildFieldLabel('SEXUAL ORIENTATION', isDark),
            _buildDropdown(
              value: _sexualOrientation,
              items: _orientations,
              onChanged: (val) => setState(() => _sexualOrientation = val!),
              cardBg: cardBg,
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Connection Preferences
            _buildFieldLabel('CONNECTION INTENT', isDark),
            _buildDropdown(
              value: _connectionPreference,
              items: _preferences,
              onChanged: (val) => setState(() => _connectionPreference = val!),
              cardBg: cardBg,
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Short Bio
            _buildFieldLabel('SHORT BIO', isDark),
            TextField(
              controller: _bioController,
              maxLines: 4,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.adaptiveBorder(isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.adaptiveBorder(isDark)),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.adaptiveAccent(isDark),
                foregroundColor: AppColors.adaptiveOnAccent(isDark),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saveProfile,
              child: const Text('Save Profile Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.adaptiveAccent(isDark),
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    required Color cardBg,
    required Color textColor,
    required Color hintColor,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor),
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.adaptiveBorder(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.adaptiveBorder(isDark)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color cardBg,
    required Color textColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveBorder(isDark)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: cardBg,
          style: TextStyle(color: textColor, fontSize: 14),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
