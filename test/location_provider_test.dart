import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:amora_frontend/providers/location_provider.dart';
import 'package:amora_frontend/services/api_service.dart';
import 'package:amora_frontend/models/location.dart' as models;

class _FakeApiService extends ApiService {
  models.Location? lastUpdated;
  models.Location partner = models.Location(
    id: 'p1', userId: 'p1', latitude: 37.7749, longitude: -122.4194, updatedAt: DateTime.now(),
  );

  @override
  Future<models.Location> updateLocation(models.UpdateLocationRequest request) async {
    lastUpdated = models.Location(
      id: 'me', userId: 'me', latitude: request.latitude, longitude: request.longitude, updatedAt: DateTime.now(),
    );
    return lastUpdated!;
  }

  @override
  Future<models.Location> getPartnerLocation() async {
    return partner;
  }
}

void main() {
  test('LocationProvider updates myLocation and pushes to API', () async {
    final controller = StreamController<Position>();
    final fakeApi = _FakeApiService();
    final provider = LocationProvider(
      apiService: fakeApi,
      positionStream: controller.stream,
      requestPermissionCallback: () async => true,
    );

    // Start tracking (uses injected permission callback)
    unawaited(provider.startTracking());

    controller.add(Position(
      longitude: -0.1276,
      latitude: 51.5072,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    ));

    // Allow microtask queue to process
    await Future.delayed(const Duration(milliseconds: 50));

    expect(fakeApi.lastUpdated, isNotNull);
    expect(fakeApi.lastUpdated!.latitude, 51.5072);
    expect(fakeApi.lastUpdated!.longitude, -0.1276);

    await controller.close();
  });

  test('LocationProvider fetches partner location', () async {
    final fakeApi = _FakeApiService();
    final provider = LocationProvider(apiService: fakeApi);

    await provider.refreshPartnerLocation();
    expect(provider.partnerLocation, isNotNull);
    expect(provider.partnerLocation!.latitude, 37.7749);
  });
}

