import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/calendar_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/calendar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/romantic_background.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  
  const CalendarScreen({super.key, this.onNavigateToProfile});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;
  bool _showHeartShadow = false;
  Offset? _heartPosition;

  @override
  void initState() {
    super.initState();
    
    // Initialize heart animation controller
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _heartScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _heartOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventsIfPartnerExists();
    });
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _loadEventsIfPartnerExists() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Only load calendar events if user has a partner
    if (authProvider.user?.partnerId != null) {
      print('📅 CalendarScreen: Loading events for user with partner: ${authProvider.user?.partnerId}');
      Provider.of<CalendarProvider>(context, listen: false).loadEvents();
    } else {
      print('📅 CalendarScreen: No partner connected, skipping events load');
    }
  }

  void _triggerHeartAnimation(Offset position) {
    setState(() {
      _heartPosition = position;
      _showHeartShadow = true;
    });
    
    _heartAnimationController.forward().then((_) {
      setState(() {
        _showHeartShadow = false;
      });
      _heartAnimationController.reset();
    });
  }

  Widget _buildHeartShadow() {
    if (!_showHeartShadow || _heartPosition == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _heartPosition!.dx - 20,
      top: _heartPosition!.dy - 20,
      child: AnimatedBuilder(
        animation: _heartAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _heartScaleAnimation.value,
            child: Opacity(
              opacity: _heartOpacityAnimation.value,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.pink,
                  size: 30,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCreateEventDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = _selectedDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      final success = await calendarProvider.createEvent(
        nameController.text.trim(),
        selectedDate,
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(calendarProvider.error ?? 'Failed to create event'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteEvent(CalendarEvent event) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.eventName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      final success = await calendarProvider.deleteEvent(event.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(calendarProvider.error ?? 'Failed to delete event'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendar'),
            backgroundColor: themeProvider.isDarkMode 
                ? AppColors.darkLavender 
                : AppColors.lovePink,
            foregroundColor: themeProvider.isDarkMode 
                ? AppColors.lightGrey 
                : AppColors.textDark,
            elevation: 0,
          ),
          body: RomanticBackground(
            themeProvider: themeProvider,
            child: Consumer2<CalendarProvider, AuthProvider>(
              builder: (context, calendarProvider, authProvider, child) {
                // Check if user has a partner connected
                if (authProvider.user?.partnerId == null) {
                  return _buildPartnerRequiredView(context, authProvider);
                }

                if (calendarProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final eventsForSelectedDate = calendarProvider.getEventsForDate(_selectedDate);

                return Column(
                  children: [
                    // Partner Connected Banner
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.green[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Connected with your partner! 💕',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Calendar Widget
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Stack(
                        children: [
                          TableCalendar<CalendarEvent>(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _selectedDate,
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDate, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDate = selectedDay;
                              });
                            },
                            onDayTap: (position) {
                              _triggerHeartAnimation(position);
                            },
                            eventLoader: (day) {
                              return calendarProvider.getEventsForDate(day);
                            },
                            calendarStyle: CalendarStyle(
                              outsideDaysVisible: false,
                              selectedDecoration: const BoxDecoration(
                                color: Colors.pink,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: Colors.pink[100],
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.pink),
                              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.pink),
                            ),
                          ),
                          _buildHeartShadow(),
                        ],
                      ),
                    ),

                    // Events for selected date
                    Expanded(
                      child: eventsForSelectedDate.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.event, size: 80, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No events on ${_formatDate(_selectedDate)}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Plan something special with your partner!',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _showCreateEventDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Event'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => calendarProvider.loadEvents(),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: eventsForSelectedDate.length,
                                itemBuilder: (context, index) {
                                  final event = eventsForSelectedDate[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: ListTile(
                                      leading: const CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Icon(Icons.event, color: Colors.white),
                                      ),
                                      title: Text(event.eventName),
                                      subtitle: Text(event.description),
                                      trailing: IconButton(
                                        onPressed: () => _deleteEvent(event),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          floatingActionButton: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              // Only show FAB if user has a partner
              if (authProvider.user?.partnerId == null) {
                return const SizedBox.shrink();
              }
              
              return FloatingActionButton(
                onPressed: _showCreateEventDialog,
                backgroundColor: Colors.pink,
                child: const Icon(Icons.add, color: Colors.white),
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToProfile() {
    if (widget.onNavigateToProfile != null) {
      widget.onNavigateToProfile!();
    } else {
      // Fallback: show a dialog with instructions
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connect with Partner'),
          content: const Text('Please go to the Profile tab to connect with your partner.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPartnerRequiredView(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'Connect with Your Partner',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Calendar features are available when you\'re connected with your partner. Share special moments and plan events together!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to profile screen to connect with partner
                _navigateToProfile();
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Connect with Partner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Go to Profile → Partner Connection',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Simple TableCalendar implementation
class TableCalendar<T> extends StatefulWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final bool Function(DateTime) selectedDayPredicate;
  final void Function(DateTime, DateTime) onDaySelected;
  final List<T> Function(DateTime) eventLoader;
  final CalendarStyle calendarStyle;
  final HeaderStyle headerStyle;
  final void Function(Offset)? onDayTap;

  const TableCalendar({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDayPredicate,
    required this.onDaySelected,
    required this.eventLoader,
    required this.calendarStyle,
    required this.headerStyle,
    this.onDayTap,
  });

  @override
  State<TableCalendar<T>> createState() => _TableCalendarState<T>();
}

class _TableCalendarState<T> extends State<TableCalendar<T>> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                  });
                },
                icon: widget.headerStyle.leftChevronIcon ?? const Icon(Icons.chevron_left),
              ),
              Text(
                '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                  });
                },
                icon: widget.headerStyle.rightChevronIcon ?? const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // Calendar Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Weekday headers
              Row(
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              // Calendar days
              ..._buildCalendarGrid(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    
    final List<Widget> rows = [];
    List<Widget> currentRow = [];
    
    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstWeekday; i++) {
      currentRow.add(const Expanded(child: SizedBox(height: 46)));
    }
    
    // Add days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, day);
      final events = widget.eventLoader(date);
      final isSelected = widget.selectedDayPredicate(date);
      final isToday = isSameDay(date, DateTime.now());
      
      currentRow.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              widget.onDaySelected(date, date);
              if (widget.onDayTap != null) {
                // Get the global position of the tapped day
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                widget.onDayTap!(position);
              }
            },
            child: Container(
              height: 46,
              margin: const EdgeInsets.all(2),
              child: Stack(
                children: [
                  // Background decoration
                  if (isSelected)
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          size: const Size(52, 52),
                          painter: HeartPainter(
                            color: widget.calendarStyle.selectedDecoration?.color ?? Colors.pink,
                          ),
                        ),
                      ),
                    )
                  else if (isToday)
                    Container(
                      decoration: BoxDecoration(
                        color: widget.calendarStyle.todayDecoration?.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  // Day number
                  Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? Colors.pink
                                : null,
                        fontWeight: isSelected ? FontWeight.w900 : (isToday ? FontWeight.bold : null),
                        fontSize: isSelected ? 16 : 14,
                        shadows: isSelected ? [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                    ),
                  ),
                  // Event marker
                  if (events.isNotEmpty)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      
      if (currentRow.length == 7) {
        rows.add(Row(children: currentRow));
        currentRow = [];
      }
    }
    
    // Add remaining empty cells to complete the current row
    while (currentRow.length < 7) {
      currentRow.add(const Expanded(child: SizedBox(height: 46)));
    }
    if (currentRow.isNotEmpty) {
      rows.add(Row(children: currentRow));
    }
    
    // Ensure we always have exactly 6 rows (42 cells total) for consistent UI
    while (rows.length < 6) {
      rows.add(Row(children: List.generate(7, (index) => const Expanded(child: SizedBox(height: 46)))));
    }
    
    return rows;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class CalendarStyle {
  final bool outsideDaysVisible;
  final BoxDecoration? selectedDecoration;
  final BoxDecoration? todayDecoration;
  final BoxDecoration? markerDecoration;

  const CalendarStyle({
    this.outsideDaysVisible = true,
    this.selectedDecoration,
    this.todayDecoration,
    this.markerDecoration,
  });
}

class HeaderStyle {
  final bool formatButtonVisible;
  final bool titleCentered;
  final Widget? leftChevronIcon;
  final Widget? rightChevronIcon;

  const HeaderStyle({
    this.formatButtonVisible = true,
    this.titleCentered = false,
    this.leftChevronIcon,
    this.rightChevronIcon,
  });
}

class HeartPainter extends CustomPainter {
  final Color color;

  HeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Heart shape path
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;
    
    // Scale factor to fit the heart in the container
    final scale = math.min(width, height) / 40;
    
    // Heart shape coordinates (scaled)
    final leftCurve = centerX - 8 * scale;
    final rightCurve = centerX + 8 * scale;
    final topCurve = centerY - 6 * scale;
    final bottomPoint = centerY + 10 * scale;
    
    // Start from the bottom point
    path.moveTo(centerX, bottomPoint);
    
    // Left curve
    path.cubicTo(
      centerX - 10 * scale, centerY + 2 * scale,
      leftCurve, topCurve,
      centerX, centerY - 2 * scale,
    );
    
    // Right curve
    path.cubicTo(
      rightCurve, topCurve,
      centerX + 10 * scale, centerY + 2 * scale,
      centerX, bottomPoint,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is HeartPainter && oldDelegate.color != color;
  }
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
