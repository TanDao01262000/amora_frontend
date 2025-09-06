import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'routines_screen.dart';
import 'timeline_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/simple_background.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          onNavigateToProfile: () => _navigateToTab(4),
          onNavigateToRoutines: () => _navigateToTab(1),
          onNavigateToTimeline: () => _navigateToTab(2),
          onNavigateToCalendar: () => _navigateToTab(3),
        );
      case 1:
        return const RoutinesScreen();
      case 2:
        return TimelineScreen(onNavigateToProfile: () => _navigateToTab(4));
      case 3:
        return CalendarScreen(onNavigateToProfile: () => _navigateToTab(4));
      case 4:
        return const ProfileScreen();
      default:
        return HomeScreen(
          onNavigateToProfile: () => _navigateToTab(4),
          onNavigateToRoutines: () => _navigateToTab(1),
          onNavigateToTimeline: () => _navigateToTab(2),
          onNavigateToCalendar: () => _navigateToTab(3),
        );
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: SimpleBackground(
            themeProvider: themeProvider,
            child: _getScreen(_currentIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.checklist),
                label: 'Routines',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timeline),
                label: 'Timeline',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO: Implement quick action
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}