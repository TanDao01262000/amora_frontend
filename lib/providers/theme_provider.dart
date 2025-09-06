import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

enum ThemeMode {
  light,
  dark,
  custom,
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _currentThemeMode = ThemeMode.light;
  String? _customBackgroundImage;
  bool _isBlurred = false;
  double _overlayOpacity = 0.3;

  ThemeMode get currentThemeMode => _currentThemeMode;
  String? get customBackgroundImage => _customBackgroundImage;
  bool get isBlurred => _isBlurred;
  double get overlayOpacity => _overlayOpacity;

  ThemeData get currentTheme {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.custom:
        return _customBackgroundImage != null 
            ? AppTheme.darkTheme  // Use dark theme for custom backgrounds
            : AppTheme.lightTheme;
    }
  }

  bool get isDarkMode => _currentThemeMode == ThemeMode.dark;
  bool get isCustomMode => _currentThemeMode == ThemeMode.custom;

  // Initialize theme from shared preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    final customImage = prefs.getString('custom_background');
    final blurred = prefs.getBool('is_blurred') ?? false;
    final opacity = prefs.getDouble('overlay_opacity') ?? 0.3;

    _currentThemeMode = ThemeMode.values[themeIndex];
    _customBackgroundImage = customImage;
    _isBlurred = blurred;
    _overlayOpacity = opacity;

    notifyListeners();
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _currentThemeMode = mode;
    await _saveThemeMode();
    notifyListeners();
  }

  // Set custom background image
  Future<void> setCustomBackground(String? imagePath, {bool blurred = false, double opacity = 0.3}) async {
    _customBackgroundImage = imagePath;
    _isBlurred = blurred;
    _overlayOpacity = opacity;
    _currentThemeMode = ThemeMode.custom;
    
    await _saveCustomBackground();
    notifyListeners();
  }

  // Clear custom background
  Future<void> clearCustomBackground() async {
    _customBackgroundImage = null;
    _isBlurred = false;
    _overlayOpacity = 0.3;
    _currentThemeMode = ThemeMode.light;
    
    await _clearCustomBackground();
    notifyListeners();
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_currentThemeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  // Save theme mode to shared preferences
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _currentThemeMode.index);
  }

  // Save custom background settings
  Future<void> _saveCustomBackground() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _currentThemeMode.index);
    if (_customBackgroundImage != null) {
      await prefs.setString('custom_background', _customBackgroundImage!);
    }
    await prefs.setBool('is_blurred', _isBlurred);
    await prefs.setDouble('overlay_opacity', _overlayOpacity);
  }

  // Clear custom background from shared preferences
  Future<void> _clearCustomBackground() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('custom_background');
    await prefs.setInt('theme_mode', _currentThemeMode.index);
    await prefs.setBool('is_blurred', _isBlurred);
    await prefs.setDouble('overlay_opacity', _overlayOpacity);
  }

  // Get theme mode display name
  String getThemeModeDisplayName() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return 'Light 🌞';
      case ThemeMode.dark:
        return 'Dark 🌙';
      case ThemeMode.custom:
        return 'Custom 🖼';
    }
  }

  // Get theme mode icon
  IconData getThemeModeIcon() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.custom:
        return Icons.image;
    }
  }
}
