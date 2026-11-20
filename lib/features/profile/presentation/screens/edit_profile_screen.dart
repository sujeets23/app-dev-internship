import 'package:flutter/material.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Alex');
  final _ageController = TextEditingController(text: '25');
  final _pronounsController = TextEditingController(text: 'they/them');
  final _bioController = TextEditingController(
    text:
        'Designer & creative thinker. Big on analog photography, indie poetry, specialty coffees, and queer social events across the city. Looking for meaningful dating & creative friendships.',
  );

  String _genderIdentity = 'Non-Binary';
  String _sexualOrientation = 'Queer';
  String _connectionPreference = 'Dating & Friendships';

  final List<String> _genders = ['Non-Binary', 'Woman', 'Man', 'Transgender', 'Genderfluid', 'Agender', 'Self-described'];
  final List<String> _orientations = ['Queer', 'Bisexual', 'Pansexual', 'Lesbian', 'Gay', 'Asexual', 'Questioning'];
  final List<String> _preferences = ['Dating & Friendships', 'Long-term Romantic', 'Casual Dating', 'Platonic Companionship'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _pronounsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Profile updated successfully!'),
        backgroundColor: AppColors.electricViolet,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Inclusive Profile',
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            _buildFieldLabel('DISPLAY NAME'),
            _buildTextField(_nameController, 'Your Name'),
            const SizedBox(height: 16),

            // Age Field
            _buildFieldLabel('AGE'),
            _buildTextField(_ageController, 'Your Age', keyboardType: TextInputType.number),
            const SizedBox(height: 16),

            // Custom Pronouns
            _buildFieldLabel('CUSTOM PRONOUNS'),
            _buildTextField(_pronounsController, 'e.g. they/them, she/her, he/they'),
            const SizedBox(height: 16),

            // Gender Identity Dropdown
            _buildFieldLabel('GENDER IDENTITY'),
            _buildDropdown(
              value: _genderIdentity,
              items: _genders,
              onChanged: (val) => setState(() => _genderIdentity = val!),
            ),
            const SizedBox(height: 16),

            // Sexual Orientation Dropdown
            _buildFieldLabel('SEXUAL ORIENTATION'),
            _buildDropdown(
              value: _sexualOrientation,
              items: _orientations,
              onChanged: (val) => setState(() => _sexualOrientation = val!),
            ),
            const SizedBox(height: 16),

            // Connection Preferences
            _buildFieldLabel('CONNECTION INTENT'),
            _buildDropdown(
              value: _connectionPreference,
              items: _preferences,
              onChanged: (val) => setState(() => _connectionPreference = val!),
            ),
            const SizedBox(height: 16),

            // Short Bio
            _buildFieldLabel('SHORT BIO'),
            TextField(
              controller: _bioController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 28),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricViolet,
                foregroundColor: Colors.white,
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.neonLime,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMutedDark),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceDark,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
