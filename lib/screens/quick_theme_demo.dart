import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart' as theme_provider;
import '../theme/app_theme.dart';
import '../widgets/romantic_background.dart';

class QuickThemeDemo extends StatelessWidget {
  const QuickThemeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('🌸 Theme Demo'),
            backgroundColor: AppColors.lovePink,
            foregroundColor: AppColors.textDark,
            actions: [
              IconButton(
                icon: Icon(themeProvider.getThemeModeIcon()),
                onPressed: () => Navigator.pushNamed(context, '/theme-settings'),
              ),
            ],
          ),
          body: RomanticBackground(
            themeProvider: themeProvider,
            enableSeasonalOverlays: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Theme Info
                  RomanticCard(
                    hasGradientBorder: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppGradients.loveGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Theme: ${themeProvider.getThemeModeDisplayName()}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Beautiful romantic theme with animated gradients and seasonal overlays!',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Color Palette
                  Text(
                    '🎨 Color Palette',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildColorSwatch('Love Pink', AppColors.lovePink),
                      _buildColorSwatch('Romance Purple', AppColors.romancePurple),
                      _buildColorSwatch('Fresh Love', AppColors.freshLove),
                      _buildColorSwatch('Soft Peach', AppColors.softPeach),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Gradients
                  Text(
                    '🌈 Gradients',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildGradientCard('Love Gradient', AppGradients.loveGradient),
                  const SizedBox(height: 8),
                  _buildGradientCard('Romance Gradient', AppGradients.romanceGradient),
                  const SizedBox(height: 8),
                  _buildGradientCard('Fresh Gradient', AppGradients.freshGradient),
                  
                  const SizedBox(height: 20),
                  
                  // Buttons
                  Text(
                    '💕 Romantic Buttons',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  RomanticButton(
                    text: 'Primary Button',
                    icon: Icons.favorite,
                    onPressed: () => _showSnackBar(context, 'Primary button pressed! 💕'),
                  ),
                  const SizedBox(height: 12),
                  RomanticButton(
                    text: 'Secondary Button',
                    icon: Icons.star,
                    isPrimary: false,
                    onPressed: () => _showSnackBar(context, 'Secondary button pressed! ⭐'),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Theme Controls
                  Text(
                    '⚙️ Theme Controls',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  RomanticCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.light_mode, color: AppColors.lovePink),
                          title: const Text('Light Theme'),
                          trailing: themeProvider.currentThemeMode == theme_provider.ThemeMode.light
                              ? const Icon(Icons.check, color: AppColors.lovePink)
                              : null,
                          onTap: () {
                            themeProvider.setThemeMode(theme_provider.ThemeMode.light);
                            _showSnackBar(context, 'Switched to Light Theme! 🌞');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.dark_mode, color: AppColors.romancePurple),
                          title: const Text('Dark Theme'),
                          trailing: themeProvider.currentThemeMode == theme_provider.ThemeMode.dark
                              ? const Icon(Icons.check, color: AppColors.romancePurple)
                              : null,
                          onTap: () {
                            themeProvider.setThemeMode(theme_provider.ThemeMode.dark);
                            _showSnackBar(context, 'Switched to Dark Theme! 🌙');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.settings, color: AppColors.freshLove),
                          title: const Text('Theme Settings'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.pushNamed(context, '/theme-settings'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Seasonal Features
                  Text(
                    '🎭 Seasonal Features',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  RomanticCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: AppColors.lovePink),
                            const SizedBox(width: 8),
                            Text(
                              'Floating Hearts',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Always active for romantic atmosphere'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.celebration, color: AppColors.romancePurple),
                            const SizedBox(width: 8),
                            Text(
                              'Special Days',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Valentine\'s Day: Enhanced hearts\nChristmas: Falling snowflakes'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.softShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientCard(String name, LinearGradient gradient) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.softShadow,
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.lovePink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
