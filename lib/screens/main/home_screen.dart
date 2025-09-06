import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/timeline_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user.dart';
import '../../widgets/simple_background.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToRoutines;
  final VoidCallback? onNavigateToTimeline;
  final VoidCallback? onNavigateToCalendar;
  
  const HomeScreen({
    super.key, 
    this.onNavigateToProfile,
    this.onNavigateToRoutines,
    this.onNavigateToTimeline,
    this.onNavigateToCalendar,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PartnerInfo? _cachedPartnerInfo;
  bool _isLoadingPartnerInfo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    print('🏠 HomeScreen: Loading all data...');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Only load data if user is properly authenticated
    if (!authProvider.isAuthenticated || authProvider.user == null) {
      print('🏠 HomeScreen: User not authenticated, skipping data load');
      return;
    }
    
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    final timelineProvider = Provider.of<TimelineProvider>(context, listen: false);
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

    // Only load partner-dependent data if user has a partner
    final hasPartner = authProvider.user?.partnerId != null;
    print('🏠 HomeScreen: User has partner: $hasPartner');

    final futures = <Future>[
      routineProvider.loadRoutines(),
    ];

    if (hasPartner) {
      futures.addAll([
        timelineProvider.loadTimeline(),
        calendarProvider.loadEvents(),
        _loadPartnerInfo(authProvider),
      ]);
    }

    await Future.wait(futures);
    print('🏠 HomeScreen: All data loaded');
  }

  Future<void> _loadPartnerInfo(AuthProvider authProvider) async {
    if (_isLoadingPartnerInfo) return;
    
    setState(() {
      _isLoadingPartnerInfo = true;
    });

    try {
      final partnerInfo = await authProvider.getPartnerInfo();
      if (mounted) {
        setState(() {
          _cachedPartnerInfo = partnerInfo;
          _isLoadingPartnerInfo = false;
        });
        print('🏠 HomeScreen: Partner info loaded: ${partnerInfo?.username}');
      }
    } catch (e) {
      print('❌ HomeScreen: Failed to load partner info: $e');
      if (mounted) {
        setState(() {
          _isLoadingPartnerInfo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: themeProvider.isDarkMode 
                ? AppColors.darkLavender 
                : AppColors.lovePink,
            foregroundColor: themeProvider.isDarkMode 
                ? AppColors.lightGrey 
                : AppColors.textDark,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(themeProvider.getThemeModeIcon()),
                onPressed: () => Navigator.pushNamed(context, '/theme-settings'),
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                  );
                },
              ),
            ],
          ),
          body: SimpleBackground(
            themeProvider: themeProvider,
            child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (!authProvider.isAuthenticated || authProvider.user == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Icon(
                                Icons.home,
                                color: Theme.of(context).primaryColor,
                                size: 32.0,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    authProvider.user?.username ?? 'User',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Partner Connection Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Partner Connection',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            if (authProvider.user?.partnerId != null) ...[
                              if (_isLoadingPartnerInfo)
                                const Center(child: CircularProgressIndicator())
                              else if (_cachedPartnerInfo != null) ...[
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: Text(
                                        _cachedPartnerInfo!.username.isNotEmpty
                                            ? _cachedPartnerInfo!.username[0].toUpperCase()
                                            : 'P',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _cachedPartnerInfo!.username,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Connected',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const Text('Loading partner info...'),
                              ],
                            ] else ...[
                              const Text('No partner connected yet.'),
                              const SizedBox(height: 12.0),
                              TextButton(
                                onPressed: () {
                                  // TODO: Implement partner connection
                                },
                                child: const Text('Connect with Partner'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: InkWell(
                              onTap: widget.onNavigateToRoutines,
                              borderRadius: BorderRadius.circular(12.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Icon(
                                        Icons.checklist,
                                        color: Theme.of(context).primaryColor,
                                        size: 24.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Routines',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Card(
                            child: InkWell(
                              onTap: widget.onNavigateToTimeline,
                              borderRadius: BorderRadius.circular(12.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Icon(
                                        Icons.timeline,
                                        color: Theme.of(context).primaryColor,
                                        size: 24.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Timeline',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Card(
                            child: InkWell(
                              onTap: widget.onNavigateToCalendar,
                              borderRadius: BorderRadius.circular(12.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: Theme.of(context).primaryColor,
                                        size: 24.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Calendar',
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Today's Routines
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Routines",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onNavigateToRoutines,
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Consumer<RoutineProvider>(
                      builder: (context, routineProvider, child) {
                        if (routineProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final routines = routineProvider.routines;
                        if (routines.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      size: 48.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    'All routines completed!',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Great job! You\'ve finished all your routines for today.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: routines.take(3).map((routine) {
                            final isCompleted = routine.state == 'completed';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isCompleted
                                      ? Colors.green
                                      : Theme.of(context).primaryColor,
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check
                                        : Icons.schedule,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(routine.title),
                                subtitle: Text(routine.description),
                                trailing: IconButton(
                                  icon: Icon(
                                    isCompleted
                                        ? Icons.undo
                                        : Icons.check_circle_outline,
                                  ),
                                  onPressed: () {
                                    if (isCompleted) {
                                      routineProvider.uncompleteRoutine(routine.id);
                                    } else {
                                      routineProvider.completeRoutine(routine.id);
                                    }
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          ),
        );
      },
    );
  }
}