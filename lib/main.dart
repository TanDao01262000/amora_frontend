import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/timeline_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/theme_demo_screen.dart';
import 'screens/theme_settings_screen.dart';
import 'screens/quick_theme_demo.dart';
import 'theme/app_theme.dart';
import 'widgets/simple_background.dart';

void main() {
  runApp(const AppForLoveApp());
}

class AppForLoveApp extends StatelessWidget {
  const AppForLoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => TimelineProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Amora',
            theme: themeProvider.currentTheme,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/main': (context) => const MainScreen(),
              '/theme-demo': (context) => const ThemeDemoScreen(),
              '/quick-demo': (context) => const QuickThemeDemo(),
              '/theme-settings': (context) => const ThemeSettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure the widget is fully built before initializing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Initialize theme provider first (faster)
    await themeProvider.initialize();
    
    // Initialize auth provider in background to avoid blocking UI
    unawaited(authProvider.initialize());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        print('🔧 AuthWrapper: Building - isLoading: ${authProvider.isLoading}, isAuthenticated: ${authProvider.isAuthenticated}');
        
        if (authProvider.isLoading) {
          print('🔧 AuthWrapper: Showing loading screen');
          return Scaffold(
            body: SimpleBackground(
              themeProvider: themeProvider,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 80,
                      color: AppColors.lovePink,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Amora',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 32),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.lovePink),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          print('🔧 AuthWrapper: User is authenticated, showing MainScreen');
          return const MainScreen();
        } else {
          print('🔧 AuthWrapper: User is not authenticated, showing LoginScreen');
          return const LoginScreen();
        }
      },
    );
  }
}
