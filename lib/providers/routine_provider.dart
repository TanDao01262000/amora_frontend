import 'package:flutter/foundation.dart';
import '../models/routine.dart';
import '../services/api_service.dart';

enum RoutineFilter { all, completed, pending, skipped }

class RoutineProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Routine> _routines = [];
  bool _isLoading = false;
  String? _error;
  RoutineFilter _currentFilter = RoutineFilter.all;
  DateTime? _lastLoadTime;
  static const Duration _cacheExpiry = Duration(minutes: 2); // Cache for 2 minutes

  List<Routine> get routines => _routines;
  bool get isLoading => _isLoading;
  String? get error => _error;
  RoutineFilter get currentFilter => _currentFilter;

  // Load all routines with caching
  Future<void> loadRoutines({bool forceRefresh = false}) async {
    // Check if we have valid cached data
    if (!forceRefresh && 
        _routines.isNotEmpty && 
        _lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!) < _cacheExpiry) {
      print('📋 RoutineProvider: Returning cached routines (${_routines.length} items)');
      return;
    }

    print('📋 RoutineProvider: Loading routines...');
    _setLoading(true);
    _clearError();
    
    try {
      _routines = await _apiService.getRoutines();
      _lastLoadTime = DateTime.now();
      print('📋 RoutineProvider: Loaded ${_routines.length} routines');
      for (int i = 0; i < _routines.length; i++) {
        print('📋 RoutineProvider: Routine $i - ${_routines[i].title} (state: ${_routines[i].state})');
      }
      notifyListeners();
    } catch (e) {
      print('❌ RoutineProvider: Failed to load routines: $e');
      _setError('Failed to load routines: $e');
    } finally {
      _setLoading(false);
      print('📋 RoutineProvider: Load routines complete');
    }
  }

  // Create new routine
  Future<bool> createRoutine(String title, String description) async {
    // Client-side validation
    if (title.trim().isEmpty) {
      _setError('Routine name cannot be empty');
      return false;
    }
    
    if (title.trim().length > 100) {
      _setError('Routine name must be 100 characters or less');
      return false;
    }
    
    if (description.trim().length > 500) {
      _setError('Description must be 500 characters or less');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final request = CreateRoutineRequest(
        title: title.trim(), 
        description: description.trim().isEmpty ? '' : description.trim(), 
        state: 'pending'
      );
      final routine = await _apiService.createRoutine(request);
      _routines.add(routine);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create routine: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update routine
  Future<bool> updateRoutine(String routineId, String title, String description) async {
    print('📋 RoutineProvider: Updating routine $routineId');
    print('📋 RoutineProvider: New title: $title, description: $description');
    
    // Client-side validation
    if (title.trim().isEmpty) {
      _setError('Routine name cannot be empty');
      return false;
    }
    
    if (title.trim().length > 100) {
      _setError('Routine name must be 100 characters or less');
      return false;
    }
    
    if (description.trim().length > 500) {
      _setError('Description must be 500 characters or less');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // Find the existing routine to preserve lastCompleted
      final existingRoutine = _routines.firstWhere((r) => r.id == routineId);
      
      final request = UpdateRoutineRequest(
        title: title.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        lastCompleted: existingRoutine.lastCompleted?.toIso8601String(),
      );
      print('📋 RoutineProvider: Request object: ${request.toJson()}');
      final updatedRoutine = await _apiService.updateRoutine(routineId, request);
      print('📋 RoutineProvider: API call successful, updating routine in list');
      
      final index = _routines.indexWhere((r) => r.id == routineId);
      if (index != -1) {
        _routines[index] = updatedRoutine;
        notifyListeners();
        print('📋 RoutineProvider: Routine updated successfully');
      } else {
        print('❌ RoutineProvider: Routine not found in list with ID: $routineId');
      }
      return true;
    } catch (e) {
      print('❌ RoutineProvider: Failed to update routine: $e');
      _setError('Failed to update routine: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark routine with specific state
  Future<bool> markRoutine(String routineId, String state) async {
    print('📋 RoutineProvider: Marking routine $routineId as $state');
    
    // Validate state value
    final validStates = ['pending', 'completed', 'skipped'];
    if (!validStates.contains(state.toLowerCase())) {
      _setError('Invalid state: $state. Must be one of: ${validStates.join(', ')}');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final updatedRoutine = await _apiService.markRoutine(routineId, state.toLowerCase());
      print('📋 RoutineProvider: API call successful, updating routine in list');
      
      // Update the routine in the list
      final index = _routines.indexWhere((r) => r.id == routineId);
      if (index != -1) {
        _routines[index] = updatedRoutine;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      print('❌ RoutineProvider: Failed to mark routine: $e');
      _setError('Failed to mark routine: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Unmark routine (set back to pending)
  Future<bool> unmarkRoutine(String routineId) async {
    print('📋 RoutineProvider: Unmarking routine $routineId');
    _setLoading(true);
    _clearError();
    
    try {
      final updatedRoutine = await _apiService.unmarkRoutine(routineId);
      print('📋 RoutineProvider: API call successful, updating routine in list');
      
      // Update the routine in the list
      final index = _routines.indexWhere((r) => r.id == routineId);
      if (index != -1) {
        _routines[index] = updatedRoutine;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      print('❌ RoutineProvider: Failed to unmark routine: $e');
      _setError('Failed to unmark routine: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Skip routine
  Future<bool> skipRoutine(String routineId) async {
    return await markRoutine(routineId, 'skipped');
  }

  // Legacy methods for backward compatibility
  Future<bool> completeRoutine(String routineId) async {
    return await markRoutine(routineId, 'completed');
  }

  Future<bool> uncompleteRoutine(String routineId) async {
    return await unmarkRoutine(routineId);
  }

  // Delete routine
  Future<bool> deleteRoutine(String routineId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _apiService.deleteRoutine(routineId);
      _routines.removeWhere((r) => r.id == routineId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete routine: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get routine by ID
  Routine? getRoutineById(String id) {
    try {
      return _routines.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get routines by state
  List<Routine> getRoutinesByState(String state) {
    return _routines.where((routine) => routine.state == state).toList();
  }

  // Get completed routines
  List<Routine> getCompletedRoutines() {
    return getRoutinesByState('completed');
  }

  // Get pending routines
  List<Routine> getPendingRoutines() {
    return getRoutinesByState('pending');
  }

  // Get skipped routines
  List<Routine> getSkippedRoutines() {
    return getRoutinesByState('skipped');
  }

  // Legacy method for backward compatibility
  List<Routine> getTodayCompletedRoutines() {
    return getCompletedRoutines();
  }

  // Get filtered routines based on current filter
  List<Routine> getFilteredRoutines() {
    switch (_currentFilter) {
      case RoutineFilter.completed:
        return getCompletedRoutines();
      case RoutineFilter.pending:
        return getPendingRoutines();
      case RoutineFilter.skipped:
        return getSkippedRoutines();
      case RoutineFilter.all:
        return _routines;
    }
  }

  // Set filter and notify listeners
  void setFilter(RoutineFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Check if routine is completed
  bool isCompleted(Routine routine) {
    return routine.state == 'completed';
  }

  // Check if routine is pending
  bool isPending(Routine routine) {
    return routine.state == 'pending';
  }

  // Check if routine is skipped
  bool isSkipped(Routine routine) {
    return routine.state == 'skipped';
  }

  // Legacy method for backward compatibility
  bool isCompletedToday(Routine routine) {
    return isCompleted(routine);
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
