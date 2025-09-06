import 'package:flutter/foundation.dart';
import '../models/calendar.dart';
import '../services/api_service.dart';

class CalendarProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<CalendarEvent> _events = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastLoadTime;
  static const Duration _cacheExpiry = Duration(minutes: 5); // Cache for 5 minutes (calendar changes less frequently)

  List<CalendarEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load calendar events with caching
  Future<void> loadEvents({bool forceRefresh = false}) async {
    // Check if we have valid cached data
    if (!forceRefresh && 
        _events.isNotEmpty && 
        _lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!) < _cacheExpiry) {
      print('📅 CalendarProvider: Returning cached calendar events (${_events.length} items)');
      return;
    }

    print('📅 CalendarProvider: Loading calendar events...');
    _setLoading(true);
    _clearError();
    
    try {
      _events = await _apiService.getCalendarEvents();
      _lastLoadTime = DateTime.now();
      print('📅 CalendarProvider: Loaded ${_events.length} calendar events');
      for (int i = 0; i < _events.length; i++) {
        final event = _events[i];
        print('📅 CalendarProvider: Event $i - ${event.eventName} on ${event.eventDate} (Relationship: ${event.relationshipId})');
      }
      // Sort by event date
      _events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      notifyListeners();
    } catch (e) {
      print('❌ CalendarProvider: Failed to load calendar events: $e');
      _setError('Failed to load calendar events: $e');
    } finally {
      _setLoading(false);
      print('📅 CalendarProvider: Load calendar events complete');
    }
  }

  // Create new calendar event
  Future<bool> createEvent(String eventName, DateTime eventDate, {String? description}) async {
    print('📅 CalendarProvider: Creating calendar event - $eventName on $eventDate');
    _setLoading(true);
    _clearError();
    
    try {
      final request = CreateCalendarEventRequest(
        eventName: eventName,
        eventDate: '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}',
        description: description,
      );
      final event = await _apiService.createCalendarEvent(request);
      _events.add(event);
      // Re-sort events
      _events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      print('📅 CalendarProvider: Successfully created event - ${event.eventName} (ID: ${event.id})');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ CalendarProvider: Failed to create calendar event: $e');
      _setError('Failed to create calendar event: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete calendar event
  Future<bool> deleteEvent(String eventId) async {
    print('📅 CalendarProvider: Deleting calendar event - ID: $eventId');
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.deleteCalendarEvent(eventId);
      final removedCount = _events.length;
      _events.removeWhere((event) => event.id == eventId);
      final newCount = _events.length;
      print('📅 CalendarProvider: Successfully deleted event. Removed ${removedCount - newCount} event(s)');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ CalendarProvider: Failed to delete calendar event: $e');
      _setError('Failed to delete calendar event: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get events for a specific date
  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.eventDate.year == date.year &&
             event.eventDate.month == date.month &&
             event.eventDate.day == date.day;
    }).toList();
  }

  // Get events for a specific month
  List<CalendarEvent> getEventsForMonth(DateTime month) {
    return _events.where((event) {
      return event.eventDate.year == month.year &&
             event.eventDate.month == month.month;
    }).toList();
  }

  // Get upcoming events (next 30 days by default)
  List<CalendarEvent> getUpcomingEvents({int days = 30}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    final upcomingEvents = _events.where((event) {
      return event.eventDate.isAfter(now) && event.eventDate.isBefore(futureDate);
    }).toList();
    
    
    return upcomingEvents;
  }

  // Get all future events (no date limit)
  List<CalendarEvent> getAllFutureEvents() {
    final now = DateTime.now();
    final futureEvents = _events.where((event) {
      return event.eventDate.isAfter(now);
    }).toList();
    
    print('📅 CalendarProvider: getAllFutureEvents() - Found ${futureEvents.length} events');
    for (int i = 0; i < futureEvents.length; i++) {
      final event = futureEvents[i];
      print('📅 CalendarProvider: Future event $i - ${event.eventName} on ${event.eventDate}');
    }
    
    return futureEvents;
  }

  // Get events for today
  List<CalendarEvent> getTodayEvents() {
    return getEventsForDate(DateTime.now());
  }

  // Check if a date has events
  bool hasEventsOnDate(DateTime date) {
    return getEventsForDate(date).isNotEmpty;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

}
