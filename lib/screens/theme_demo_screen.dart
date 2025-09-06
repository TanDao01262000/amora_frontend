import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart' as theme_provider;
import '../theme/app_theme.dart';
import '../widgets/romantic_background.dart';

class ThemeDemoScreen extends StatelessWidget {
  const ThemeDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Theme Demo'),
            backgroundColor: AppColors.lovePink,
            foregroundColor: AppColors.textDark,
            actions: [
              IconButton(
                icon: Icon(themeProvider.getThemeModeIcon()),
                onPressed: () => _showThemeOptions(context),
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
                  // Theme Info Card
                  RomanticCard(
                    hasGradientBorder: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Theme',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          themeProvider.getThemeModeDisplayName(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.romancePurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (themeProvider.isCustomMode && themeProvider.customBackgroundImage != null)
                          Text(
                            'Custom background active',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Color Palette Demo
                  Text(
                    'Color Palette',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildColorPalette(),
                  
                  const SizedBox(height: 20),
                  
                  // Gradient Demo
                  Text(
                    'Gradients',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildGradientDemo(),
                  
                  const SizedBox(height: 20),
                  
                  // Button Demo
                  Text(
                    'Romantic Buttons',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildButtonDemo(context),
                  
                  const SizedBox(height: 20),
                  
                  // Card Demo
                  Text(
                    'Romantic Cards',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildCardDemo(context),
                  
                  const SizedBox(height: 20),
                  
                  // Seasonal Features
                  Text(
                    'Seasonal Features',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSeasonalDemo(context),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPalette() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildColorSwatch('Love Pink', AppColors.lovePink),
        _buildColorSwatch('Romance Purple', AppColors.romancePurple),
        _buildColorSwatch('Fresh Love', AppColors.freshLove),
        _buildColorSwatch('Soft Peach', AppColors.softPeach),
        _buildColorSwatch('Text Dark', AppColors.textDark),
        _buildColorSwatch('Text Light', AppColors.textLight),
      ],
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

  Widget _buildGradientDemo() {
    return Column(
      children: [
        _buildGradientCard('Love Gradient', AppGradients.loveGradient),
        const SizedBox(height: 8),
        _buildGradientCard('Romance Gradient', AppGradients.romanceGradient),
        const SizedBox(height: 8),
        _buildGradientCard('Fresh Gradient', AppGradients.freshGradient),
        const SizedBox(height: 8),
        _buildGradientCard('Dark Gradient', AppGradients.darkGradient),
      ],
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

  Widget _buildButtonDemo(BuildContext context) {
    return Column(
      children: [
        RomanticButton(
          text: 'Primary Button',
          icon: Icons.favorite,
          onPressed: () => _showSnackBar(context, 'Primary button pressed!'),
        ),
        const SizedBox(height: 12),
        RomanticButton(
          text: 'Secondary Button',
          icon: Icons.star,
          isPrimary: false,
          onPressed: () => _showSnackBar(context, 'Secondary button pressed!'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RomanticButton(
                text: 'Small',
                onPressed: () => _showSnackBar(context, 'Small button!'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RomanticButton(
                text: 'Button',
                onPressed: () => _showSnackBar(context, 'Another button!'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardDemo(BuildContext context) {
    return Column(
      children: [
        RomanticCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: AppColors.lovePink),
                  const SizedBox(width: 8),
                  Text(
                    'Regular Card',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('This is a regular romantic card with soft shadows and rounded corners.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        RomanticCard(
          hasGradientBorder: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.romancePurple),
                  const SizedBox(width: 8),
                  Text(
                    'Gradient Border Card',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('This card has a beautiful gradient border and background overlay.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonalDemo(BuildContext context) {
    return RomanticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.celebration, color: AppColors.freshLove),
              const SizedBox(width: 8),
              Text(
                'Seasonal Features',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('• Floating hearts are always active for romantic atmosphere'),
          const Text('• Special Valentine\'s Day effects on February 14th'),
          const Text('• Snowflakes appear on Christmas Day'),
          const Text('• Animated gradient backgrounds'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showSnackBar(context, 'Seasonal features are active! 💕'),
            icon: const Icon(Icons.favorite),
            label: const Text('Test Seasonal Effects'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lovePink,
              foregroundColor: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeOptions(BuildContext context) {
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
              'Quick Theme Switch',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.light_mode, color: AppColors.lovePink),
              title: const Text('Light Theme'),
              onTap: () {
                Provider.of<theme_provider.ThemeProvider>(context, listen: false)
                    .setThemeMode(theme_provider.ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: AppColors.romancePurple),
              title: const Text('Dark Theme'),
              onTap: () {
                Provider.of<theme_provider.ThemeProvider>(context, listen: false)
                    .setThemeMode(theme_provider.ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.freshLove),
              title: const Text('Theme Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/theme-settings');
              },
            ),
          ],
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
