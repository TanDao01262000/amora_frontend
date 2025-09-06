import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'custom_background.dart';

/// A comprehensive romantic background widget that combines
/// custom backgrounds, seasonal overlays, and animated gradients
class RomanticBackground extends StatelessWidget {
  final Widget child;
  final ThemeProvider themeProvider;
  final bool enableSeasonalOverlays;

  const RomanticBackground({
    super.key,
    required this.child,
    required this.themeProvider,
    this.enableSeasonalOverlays = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget backgroundWidget = CustomBackground(
      themeProvider: themeProvider,
      child: child,
    );

    if (enableSeasonalOverlays) {
      backgroundWidget = SeasonalOverlay(child: backgroundWidget);
    }

    return backgroundWidget;
  }
}

/// Enhanced gradient button with romantic styling
class RomanticButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final double? width;

  const RomanticButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        gradient: isPrimary 
            ? (themeProvider.isDarkMode 
                ? AppGradients.darkGradient
                : AppGradients.loveGradient)
            : (themeProvider.isDarkMode 
                ? LinearGradient(
                    colors: [AppColors.darkLavender.withOpacity(0.4), AppColors.romancePurple.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppGradients.romanceGradient),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isPrimary 
                ? AppColors.lovePink.withOpacity(0.3)
                : AppColors.romancePurple.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isPrimary 
              ? AppColors.lovePink.withOpacity(0.3)
              : AppColors.romancePurple.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          minimumSize: Size(width ?? double.infinity, 50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Romantic card with soft shadows and gradient borders
class RomanticCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool hasGradientBorder;

  const RomanticCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.hasGradientBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode 
            ? AppColors.darkLavender.withOpacity(0.8)
            : AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softShadow,
        border: hasGradientBorder 
            ? Border.all(
                width: 1,
                color: themeProvider.isDarkMode 
                    ? AppColors.lightGrey.withOpacity(0.2)
                    : AppColors.textDark.withOpacity(0.1),
              )
            : Border.all(
                width: 0.5,
                color: themeProvider.isDarkMode 
                    ? AppColors.lightGrey.withOpacity(0.1)
                    : AppColors.textDark.withOpacity(0.05),
              ),
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: hasGradientBorder 
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    AppColors.lovePink.withOpacity(0.1),
                    AppColors.romancePurple.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: child,
      ),
    );
  }
}

/// Animated floating hearts widget for special occasions
class FloatingHeartsWidget extends StatefulWidget {
  final int heartCount;
  final double speed;

  const FloatingHeartsWidget({
    super.key,
    this.heartCount = 5,
    this.speed = 1.0,
  });

  @override
  State<FloatingHeartsWidget> createState() => _FloatingHeartsWidgetState();
}

class _FloatingHeartsWidgetState extends State<FloatingHeartsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.heartCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: (2000 + index * 200) ~/ widget.speed),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.heartCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            final progress = _animations[index].value;
            final size = 20.0 + (math.sin(progress * math.pi) * 10);
            final opacity = 0.3 + (math.sin(progress * math.pi) * 0.4);
            
            return Positioned(
              left: 50.0 + (index * 60.0) + (math.sin(progress * math.pi * 2) * 20),
              top: 100.0 + (index * 80.0) + (math.cos(progress * math.pi * 2) * 30),
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  Icons.favorite,
                  color: AppColors.lovePink,
                  size: size,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Seasonal decoration widget
class SeasonalDecoration extends StatelessWidget {
  final Widget child;
  final bool enableHearts;
  final bool enableSnow;

  const SeasonalDecoration({
    super.key,
    required this.child,
    this.enableHearts = true,
    this.enableSnow = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    return Stack(
      children: [
        child,
        if (enableHearts && (month == 2 && day == 14 || enableHearts))
          const Positioned.fill(
            child: FloatingHeartsWidget(heartCount: 8),
          ),
        if (enableSnow && month == 12 && day == 25)
          Positioned.fill(
            child: CustomPaint(
              painter: SnowflakesPainter(0.0),
            ),
          ),
      ],
    );
  }
}
