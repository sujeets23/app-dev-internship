import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';

/// Interactive profile photo selector with camera/gallery and avatar presets
class AvatarPickerWidget extends StatelessWidget {
  final String? imagePath;
  final String? presetAvatarId;
  final ValueChanged<String?> onImageSelected;
  final ValueChanged<String?> onPresetAvatarSelected;

  const AvatarPickerWidget({
    super.key,
    this.imagePath,
    this.presetAvatarId,
    required this.onImageSelected,
    required this.onPresetAvatarSelected,
  });

  static const List<Map<String, dynamic>> presetAvatars = [
    {
      'id': 'avatar_sunset',
      'label': 'Sunset Glow',
      'color1': Color(0xFFF78CA0),
      'color2': Color(0xFFFE9A8B),
      'icon': Icons.flare_rounded,
    },
    {
      'id': 'avatar_ocean',
      'label': 'Ocean Calm',
      'color1': Color(0xFF2C5E68),
      'color2': Color(0xFF4CA1AF),
      'icon': Icons.water_drop_rounded,
    },
    {
      'id': 'avatar_earth',
      'label': 'Warm Earth',
      'color1': Color(0xFFD98A4F),
      'color2': Color(0xFFC77740),
      'icon': Icons.spa_rounded,
    },
    {
      'id': 'avatar_lavender',
      'label': 'Lavender Dream',
      'color1': Color(0xFF8A5DA5),
      'color2': Color(0xFFA57EC3),
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        onImageSelected(file.path);
        onPresetAvatarSelected(null);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPickerBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Profile Picture',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a photo that helps people get to know the genuine you.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () => _pickImage(bottomSheetContext, ImageSource.gallery),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.secondaryLight,
                    child: Icon(Icons.camera_alt_outlined, color: AppColors.secondary),
                  ),
                  title: const Text('Take a Photo'),
                  onTap: () => _pickImage(bottomSheetContext, ImageSource.camera),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Or select an artistic avatar:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: presetAvatars.map((preset) {
                    final isSelected = presetAvatarId == preset['id'];
                    return GestureDetector(
                      onTap: () {
                        onImageSelected(null);
                        onPresetAvatarSelected(preset['id'] as String);
                        Navigator.of(bottomSheetContext).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: preset['color1'] as Color,
                          child: Icon(
                            preset['icon'] as IconData,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget avatarContent;

    if (imagePath != null && imagePath!.isNotEmpty) {
      avatarContent = kIsWeb
          ? Image.network(
              imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildPlaceholder(),
            )
          : Image.file(
              File(imagePath!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildPlaceholder(),
            );
    } else if (presetAvatarId != null) {
      final preset = presetAvatars.firstWhere(
        (p) => p['id'] == presetAvatarId,
        orElse: () => presetAvatars.first,
      );
      avatarContent = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              preset['color1'] as Color,
              preset['color2'] as Color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(
            preset['icon'] as IconData,
            color: Colors.white,
            size: 48,
          ),
        ),
      );
    } else {
      avatarContent = _buildPlaceholder();
    }

    final bool hasSelection =
        (imagePath != null && imagePath!.isNotEmpty) || presetAvatarId != null;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () => _showPickerBottomSheet(context),
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasSelection ? AppColors.primary : AppColors.border,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(child: avatarContent),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => _showPickerBottomSheet(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceDark : AppColors.surface,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => _showPickerBottomSheet(context),
            child: Text(
              hasSelection ? 'Change Photo' : 'Add Profile Photo',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryLight.withValues(alpha: 0.5),
      child: const Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: 54,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
