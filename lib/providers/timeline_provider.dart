import 'package:flutter/foundation.dart';
import '../models/timeline.dart';
import '../services/api_service.dart';

class TimelineProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<TimelineEntry> _timeline = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastLoadTime;
  static const Duration _cacheExpiry = Duration(minutes: 2); // Cache for 2 minutes

  List<TimelineEntry> get timeline => _timeline;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load timeline entries with caching
  Future<void> loadTimeline({bool forceRefresh = false}) async {
    // Check if we have valid cached data
    if (!forceRefresh && 
        _timeline.isNotEmpty && 
        _lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!) < _cacheExpiry) {
      print('📝 TimelineProvider: Returning cached timeline (${_timeline.length} items)');
      return;
    }

    print('📝 TimelineProvider: Loading timeline...');
    _setLoading(true);
    _clearError();
    
    try {
      _timeline = await _apiService.getTimeline();
      _lastLoadTime = DateTime.now();
      print('📝 TimelineProvider: Loaded ${_timeline.length} timeline entries');
      for (int i = 0; i < _timeline.length; i++) {
        print('📝 TimelineProvider: Entry $i - ${_timeline[i].note}');
      }
      // Sort by creation date (newest first)
      _timeline.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (e) {
      print('❌ TimelineProvider: Failed to load timeline: $e');
      _setError('Failed to load timeline: $e');
    } finally {
      _setLoading(false);
      print('📝 TimelineProvider: Load timeline complete');
    }
  }

  // Create new timeline entry
  Future<bool> createTimelineEntry(String note, {String? mediaUrl}) async {
    _setLoading(true);
    _clearError();
    
    try {
      final request = CreateTimelineRequest(note: note, mediaUrl: mediaUrl);
      final entry = await _apiService.createTimelineEntry(request);
      _timeline.insert(0, entry); // Add to beginning of list
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create timeline entry: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete timeline entry
  Future<bool> deleteTimelineEntry(String entryId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.deleteTimelineEntry(entryId);
      _timeline.removeWhere((entry) => entry.id == entryId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete timeline entry: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get timeline entries for a specific date
  List<TimelineEntry> getTimelineForDate(DateTime date) {
    return _timeline.where((entry) {
      return entry.createdAt.year == date.year &&
             entry.createdAt.month == date.month &&
             entry.createdAt.day == date.day;
    }).toList();
  }

  // Get recent timeline entries (last 7 days)
  List<TimelineEntry> getRecentTimeline({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _timeline.where((entry) => entry.createdAt.isAfter(cutoffDate)).toList();
  }

  // Get timeline entries with media
  List<TimelineEntry> getTimelineWithMedia() {
    return _timeline.where((entry) => entry.mediaUrl != null && entry.mediaUrl!.isNotEmpty).toList();
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
