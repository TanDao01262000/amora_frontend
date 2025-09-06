import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

/// A simple, non-animated background widget to fix performance issues
class SimpleBackground extends StatelessWidget {
  final Widget child;
  final ThemeProvider themeProvider;

  const SimpleBackground({
    super.key,
    required this.child,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (themeProvider.isCustomMode && themeProvider.customBackgroundImage != null) {
      return _buildCustomBackground();
    }
    
    return _buildDefaultBackground();
  }

  Widget _buildCustomBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(themeProvider.customBackgroundImage!)),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.lovePink.withOpacity(themeProvider.overlayOpacity),
              AppColors.romancePurple.withOpacity(themeProvider.overlayOpacity),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: themeProvider.isBlurred
            ? BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: child,
              )
            : child,
      ),
    );
  }

  Widget _buildDefaultBackground() {
    if (themeProvider.isDarkMode) {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.darkGradient,
        ),
        child: child,
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, AppColors.lovePink.withOpacity(0.1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
