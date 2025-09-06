import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class CustomBackground extends StatefulWidget {
  final Widget child;
  final ThemeProvider themeProvider;

  const CustomBackground({
    super.key,
    required this.child,
    required this.themeProvider,
  });

  @override
  State<CustomBackground> createState() => _CustomBackgroundState();
}

class _CustomBackgroundState extends State<CustomBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));
    // Only start animation if widget is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _gradientController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.themeProvider.isCustomMode && widget.themeProvider.customBackgroundImage != null) {
      return _buildCustomBackground();
    }
    
    return _buildDefaultBackground();
  }

  Widget _buildCustomBackground() {
    return FutureBuilder<FileImage>(
      future: _loadBackgroundImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a simple gradient while loading
          return _buildDefaultBackground();
        }
        
        return Container(
          decoration: BoxDecoration(
            image: snapshot.hasData 
                ? DecorationImage(
                    image: snapshot.data!,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lovePink.withOpacity(widget.themeProvider.overlayOpacity),
                      AppColors.romancePurple.withOpacity(widget.themeProvider.overlayOpacity),
                      AppColors.softPeach.withOpacity(widget.themeProvider.overlayOpacity * 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      0.0,
                      0.5 + (_gradientAnimation.value * 0.3),
                      1.0,
                    ],
                  ),
                ),
                child: widget.themeProvider.isBlurred
                    ? BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: widget.child,
                      )
                    : widget.child,
              );
            },
          ),
        );
      },
    );
  }

  Future<FileImage> _loadBackgroundImage() async {
    // Load image asynchronously to avoid blocking UI
    final file = File(widget.themeProvider.customBackgroundImage!);
    return FileImage(file);
  }

  Widget _buildDefaultBackground() {
    if (widget.themeProvider.isDarkMode) {
      return AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.deepNavy,
                  AppColors.darkLavender,
                  AppColors.romancePurple.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0.0,
                  0.5 + (_gradientAnimation.value * 0.2),
                  1.0,
                ],
              ),
            ),
            child: widget.child,
          );
        },
      );
    }
    
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.white,
                AppColors.lovePink.withOpacity(0.3),
                AppColors.softPeach.withOpacity(0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [
                0.0,
                0.6 + (_gradientAnimation.value * 0.2),
                1.0,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class SeasonalOverlay extends StatefulWidget {
  final Widget child;

  const SeasonalOverlay({super.key, required this.child});

  @override
  State<SeasonalOverlay> createState() => _SeasonalOverlayState();
}

class _SeasonalOverlayState extends State<SeasonalOverlay>
    with TickerProviderStateMixin {
  late AnimationController _heartsController;
  late AnimationController _snowController;
  late Animation<double> _heartsAnimation;
  late Animation<double> _snowAnimation;

  @override
  void initState() {
    super.initState();
    
    _heartsController = AnimationController(
      duration: const Duration(seconds: 6), // Slower animation
      vsync: this,
    );
    _heartsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartsController,
      curve: Curves.easeInOut,
    ));
    
    _snowController = AnimationController(
      duration: const Duration(seconds: 8), // Slower animation
      vsync: this,
    );
    _snowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _snowController,
      curve: Curves.linear,
    ));
    
    // Only start animations if widget is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _heartsController.repeat();
        _snowController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _heartsController.dispose();
    _snowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    // Valentine's Day (February 14)
    if (month == 2 && day == 14) {
      return _buildValentinesOverlay();
    }
    
    // Christmas (December 25)
    if (month == 12 && day == 25) {
      return _buildChristmasOverlay();
    }
    
    // Default with floating hearts
    return _buildDefaultOverlay();
  }

  Widget _buildValentinesOverlay() {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _heartsAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: FloatingHeartsPainter(_heartsAnimation.value),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChristmasOverlay() {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _snowAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: SnowflakesPainter(_snowAnimation.value),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultOverlay() {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _heartsAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: FloatingHeartsPainter(_heartsAnimation.value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FloatingHeartsPainter extends CustomPainter {
  final double animationValue;
  
  FloatingHeartsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lovePink.withOpacity(0.2) // Reduced opacity
      ..style = PaintingStyle.fill;

    // Draw fewer floating hearts with animation (reduced from 8 to 5)
    for (int i = 0; i < 5; i++) {
      final baseX = (size.width * 0.2 * i) + (size.width * 0.1);
      final baseY = (size.height * 0.15 * i) + (size.height * 0.2);
      
      // Simplified animation calculations
      final offsetX = math.sin(animationValue * math.pi + i) * 15; // Reduced movement
      final offsetY = math.cos(animationValue * math.pi + i * 0.5) * 10; // Reduced movement
      
      final x = baseX + offsetX;
      final y = baseY + offsetY;
      
      // Simplified size animation
      final heartSize = 5.0 + (math.sin(animationValue * math.pi + i) * 2); // Reduced size variation
      
      _drawHeart(canvas, paint, Offset(x, y), heartSize);
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.3,
      center.dx - size, center.dy + size * 0.1,
      center.dx, center.dy + size * 0.7,
    );
    path.cubicTo(
      center.dx + size, center.dy + size * 0.1,
      center.dx + size * 0.5, center.dy - size * 0.3,
      center.dx, center.dy + size * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SnowflakesPainter extends CustomPainter {
  final double animationValue;
  
  SnowflakesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withOpacity(0.4) // Reduced opacity
      ..style = PaintingStyle.fill;

    // Draw fewer animated snowflakes (reduced from 15 to 8)
    for (int i = 0; i < 8; i++) {
      final baseX = (size.width * 0.12 * i) + (size.width * 0.05);
      final baseY = (size.height * 0.12 * i) + (size.height * 0.1);
      
      // Simplified falling motion
      final fallOffset = (animationValue * size.height * 0.5) % size.height; // Slower fall
      final y = (baseY + fallOffset) % size.height;
      
      // Simplified horizontal drift
      final driftX = math.sin(animationValue * math.pi + i) * 5; // Reduced drift
      final x = baseX + driftX;
      
      // Simplified rotation
      final rotation = animationValue * math.pi + i; // Slower rotation
      
      _drawSnowflake(canvas, paint, Offset(x, y), 3.0, rotation); // Smaller size
    }
  }

  void _drawSnowflake(Canvas canvas, Paint paint, Offset center, double size, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    // Simple snowflake pattern
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final endX = size * 2 * math.cos(angle);
      final endY = size * 2 * math.sin(angle);
      
      canvas.drawLine(
        Offset.zero,
        Offset(endX, endY),
        paint..strokeWidth = 1.0,
      );
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

