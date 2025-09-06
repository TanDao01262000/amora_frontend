import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/theme_provider.dart' as theme_provider;
import '../theme/app_theme.dart';
import '../widgets/custom_background.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isBlurred = false;
  double _overlayOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: AppColors.lovePink,
        foregroundColor: AppColors.textDark,
      ),
      body: Consumer<theme_provider.ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Mode Selection
                _buildSection(
                  title: 'Theme Mode',
                  child: Column(
                    children: [
                      _buildThemeOption(
                        icon: Icons.light_mode,
                        title: 'Light Theme 🌞',
                        subtitle: 'Bright and romantic pastel theme',
                        isSelected: themeProvider.currentThemeMode == theme_provider.ThemeMode.light,
                        onTap: () => themeProvider.setThemeMode(theme_provider.ThemeMode.light),
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        icon: Icons.dark_mode,
                        title: 'Dark Theme 🌙',
                        subtitle: 'Romantic night mode with deep colors',
                        isSelected: themeProvider.currentThemeMode == theme_provider.ThemeMode.dark,
                        onTap: () => themeProvider.setThemeMode(theme_provider.ThemeMode.dark),
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        icon: Icons.image,
                        title: 'Custom Background 🖼',
                        subtitle: 'Use your own photo as background',
                        isSelected: themeProvider.currentThemeMode == theme_provider.ThemeMode.custom,
                        onTap: () => _showCustomBackgroundOptions(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Current Theme Preview
                _buildSection(
                  title: 'Preview',
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.romancePurple.withOpacity(0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomBackground(
                        themeProvider: themeProvider,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amora',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: themeProvider.isDarkMode ? AppColors.lightGrey : AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your romantic journey together 💕',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: themeProvider.isDarkMode ? AppColors.lightGrey : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Custom Background Options
                if (themeProvider.isCustomMode) ...[
                  _buildSection(
                    title: 'Custom Background Options',
                    child: Column(
                      children: [
                        if (themeProvider.customBackgroundImage != null) ...[
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(themeProvider.customBackgroundImage!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Blur Toggle
                        SwitchListTile(
                          title: const Text('Blur Background'),
                          subtitle: const Text('Make text more readable'),
                          value: _isBlurred,
                          onChanged: (value) {
                            setState(() {
                              _isBlurred = value;
                            });
                            themeProvider.setCustomBackground(
                              themeProvider.customBackgroundImage,
                              blurred: value,
                              opacity: _overlayOpacity,
                            );
                          },
                          activeColor: AppColors.lovePink,
                        ),
                        
                        // Overlay Opacity
                        ListTile(
                          title: const Text('Overlay Opacity'),
                          subtitle: Slider(
                            value: _overlayOpacity,
                            min: 0.0,
                            max: 0.8,
                            divisions: 8,
                            onChanged: (value) {
                              setState(() {
                                _overlayOpacity = value;
                              });
                              themeProvider.setCustomBackground(
                                themeProvider.customBackgroundImage,
                                blurred: _isBlurred,
                                opacity: value,
                              );
                            },
                            activeColor: AppColors.lovePink,
                          ),
                        ),
                        
                        // Change Background Button
                        ElevatedButton.icon(
                          onPressed: _showCustomBackgroundOptions,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Change Background'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.romancePurple,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Clear Background Button
                        TextButton.icon(
                          onPressed: () {
                            themeProvider.clearCustomBackground();
                            setState(() {
                              _isBlurred = false;
                              _overlayOpacity = 0.3;
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear Custom Background'),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Seasonal Features
                _buildSection(
                  title: 'Seasonal Features',
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.favorite, color: AppColors.lovePink),
                        title: const Text('Floating Hearts'),
                        subtitle: const Text('Always enabled for romantic atmosphere'),
                        trailing: const Icon(Icons.check, color: AppColors.freshLove),
                      ),
                      ListTile(
                        leading: const Icon(Icons.ac_unit, color: AppColors.freshLove),
                        title: const Text('Snowflakes'),
                        subtitle: const Text('Appears on Christmas Day'),
                        trailing: const Icon(Icons.check, color: AppColors.freshLove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.lovePink : AppColors.romancePurple.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.lovePink.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.lovePink : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.lovePink : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.lovePink,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showCustomBackgroundOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Background Source',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.lovePink),
              title: const Text('Take Photo'),
              subtitle: const Text('Capture a new moment'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.romancePurple),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select from your photos'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final themeProvider = Provider.of<theme_provider.ThemeProvider>(context, listen: false);
        await themeProvider.setCustomBackground(
          image.path,
          blurred: _isBlurred,
          opacity: _overlayOpacity,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Background updated successfully! 💕'),
              backgroundColor: AppColors.lovePink,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set background: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
