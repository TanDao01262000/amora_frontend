import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location.dart' as models;
import '../services/api_service.dart';

class LocationProvider with ChangeNotifier {
  final ApiService _apiService;
  final Stream<Position>? _injectedPositionStream;
  final Future<bool> Function()? _requestPermissionCallback;

  models.Location? _myLocation;
  models.Location? _partnerLocation;
  bool _permissionGranted = false;
  bool _isTracking = false;
  String? _error;
  DateTime? _lastSentAt;
  DateTime? _lastPartnerAt;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _partnerPollTimer;

  LocationProvider({ApiService? apiService, Stream<Position>? positionStream, Future<bool> Function()? requestPermissionCallback})
      : _apiService = apiService ?? ApiService(),
        _injectedPositionStream = positionStream,
        _requestPermissionCallback = requestPermissionCallback;

  models.Location? get myLocation => _myLocation;
  models.Location? get partnerLocation => _partnerLocation;
  bool get permissionGranted => _permissionGranted;
  bool get isTracking => _isTracking;
  String? get error => _error;
  DateTime? get lastSentAt => _lastSentAt;
  DateTime? get lastPartnerAt => _lastPartnerAt;

  Future<bool> requestPermission() async {
    try {
      if (_requestPermissionCallback != null) {
        final granted = await _requestPermissionCallback!();
        _permissionGranted = granted;
        if (!granted) {
          _setError('Location permission denied');
        } else {
          _clearError();
          notifyListeners();
        }
        return granted;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setError('Location services are disabled');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _permissionGranted = false;
        _setError('Location permission denied');
        return false;
      }
      if (permission == LocationPermission.deniedForever) {
        _permissionGranted = false;
        _setError('Location permissions are permanently denied');
        return false;
      }

      _permissionGranted = true;
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to request permission: $e');
      return false;
    }
  }

  Future<void> startTracking() async {
    if (_isTracking) return;
    final granted = await requestPermission();
    if (!granted) return;

    _isTracking = true;
    notifyListeners();

    final positionStream = _injectedPositionStream ?? Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    _positionSubscription = positionStream.listen((position) async {
      try {
        // Update local state immediately
        _myLocation = models.Location(
          id: 'me',
          userId: 'me',
          latitude: position.latitude,
          longitude: position.longitude,
          updatedAt: DateTime.now(),
        );
        notifyListeners();

        // Send update to backend (throttle to 2s)
        final now = DateTime.now();
        if (_lastSentAt == null || now.difference(_lastSentAt!) > const Duration(seconds: 2)) {
          final req = models.UpdateLocationRequest(
            latitude: position.latitude,
            longitude: position.longitude,
          );
          await _apiService.updateLocation(req);
          _lastSentAt = now;
          notifyListeners();
        }
      } catch (e) {
        _setError('Failed to update location: $e');
      }
    }, onError: (e) {
      _setError('Location stream error: $e');
    });
  }

  void startPartnerPolling({Duration interval = const Duration(seconds: 5)}) {
    _partnerPollTimer?.cancel();
    _partnerPollTimer = Timer.periodic(interval, (_) {
      refreshPartnerLocation();
    });
  }

  Future<void> refreshPartnerLocation() async {
    try {
      final partnerLoc = await _apiService.getPartnerLocation();
      _partnerLocation = partnerLoc;
      _lastPartnerAt = DateTime.now();
      notifyListeners();
    } catch (e) {
      // Keep polling; surface the error
      _setError('Failed to fetch partner location: $e');
    }
  }

  Future<void> stop() async {
    _isTracking = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _partnerPollTimer?.cancel();
    _partnerPollTimer = null;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _partnerPollTimer?.cancel();
    super.dispose();
  }
}

