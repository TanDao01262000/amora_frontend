import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - More Romantic and Passionate
  static const Color lovePink = Color(0xFFE91E63);        // 💕 Deep Romantic Pink
  static const Color romancePurple = Color(0xFF9C27B0);   // 💜 Rich Romance Purple
  static const Color freshLove = Color(0xFF4CAF50);       // 🌿 Fresh Love Green
  static const Color softPeach = Color(0xFFFF9800);       // 🍑 Warm Peach
  static const Color passionateRed = Color(0xFFE53E3E);   // ❤️ Passionate Red
  static const Color dreamyBlue = Color(0xFF2196F3);      // 💙 Dreamy Blue
  static const Color goldenLove = Color(0xFFFFC107);      // ✨ Golden Love
  static const Color white = Color(0xFFFEFEFE);           // ⚪ Off-White
  static const Color textDark = Color(0xFF2D3748);        // 🖤 Deeper Dark Grey
  static const Color textLight = Color(0xFF718096);       // 🤍 Softer Light Grey
  
  // Dark Theme Colors - Softer and Less Harsh
  static const Color deepNavy = Color(0xFF2A2A3E);        // Softer dark background
  static const Color darkLavender = Color(0xFF3A3A4E);    // Softer dark secondary
  static const Color lightGrey = Color(0xFFE0E0E0);       // Softer light text
  
  // Gradient Colors - More Romantic and Vibrant
  static const List<Color> loveGradient = [lovePink, passionateRed];
  static const List<Color> romanceGradient = [romancePurple, lovePink];
  static const List<Color> freshGradient = [freshLove, dreamyBlue];
  static const List<Color> passionGradient = [passionateRed, goldenLove];
  static const List<Color> dreamyGradient = [dreamyBlue, romancePurple];
  static const List<Color> sunsetGradient = [goldenLove, softPeach];
  static const List<Color> darkGradient = [darkLavender, romancePurple];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.lovePink,
        brightness: Brightness.light,
        primary: AppColors.lovePink,
        secondary: AppColors.romancePurple,
        tertiary: AppColors.freshLove,
        surface: AppColors.white,
        background: AppColors.white,
        onPrimary: AppColors.textDark,
        onSecondary: AppColors.textDark,
        onSurface: AppColors.textDark,
        onBackground: AppColors.textDark,
      ),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lovePink,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 4,
        shadowColor: AppColors.lovePink.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lovePink,
          foregroundColor: AppColors.textDark,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.romancePurple,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textDark,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textDark,
        ),
        bodySmall: TextStyle(
          color: AppColors.textLight,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.romancePurple,
        brightness: Brightness.dark,
        primary: AppColors.romancePurple,
        secondary: AppColors.lovePink,
        tertiary: AppColors.freshLove,
        surface: AppColors.deepNavy,
        background: AppColors.deepNavy,
        onPrimary: AppColors.lightGrey,
        onSecondary: AppColors.lightGrey,
        onSurface: AppColors.lightGrey,
        onBackground: AppColors.lightGrey,
      ),
      scaffoldBackgroundColor: AppColors.deepNavy,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkLavender,
        foregroundColor: AppColors.lightGrey,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.lightGrey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkLavender,
        elevation: 4,
        shadowColor: AppColors.romancePurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.romancePurple,
          foregroundColor: AppColors.lightGrey,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lovePink,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.lightGrey,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.lightGrey,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: AppColors.lightGrey,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColors.lightGrey,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightGrey,
        ),
        bodySmall: TextStyle(
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

class AppGradients {
  static const LinearGradient loveGradient = LinearGradient(
    colors: AppColors.loveGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient romanceGradient = LinearGradient(
    colors: AppColors.romanceGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient freshGradient = LinearGradient(
    colors: AppColors.freshGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient passionGradient = LinearGradient(
    colors: AppColors.passionGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient dreamyGradient = LinearGradient(
    colors: AppColors.dreamyGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: AppColors.sunsetGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: AppColors.darkGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: AppColors.textDark.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: AppColors.textDark.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color: AppColors.textDark.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
