import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/auth_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Delay start to ensure provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<LocationProvider>(context, listen: false);
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await provider.startTracking();
      if (auth.user?.partnerId != null) {
        provider.startPartnerPolling();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, loc, child) {
        final me = loc.myLocation;
        final partner = loc.partnerLocation;
        final center = partner != null
            ? LatLng(partner.latitude, partner.longitude)
            : (me != null ? LatLng(me.latitude, me.longitude) : const LatLng(0, 0));

        final markers = <Marker>[];
        if (me != null) {
          markers.add(
            Marker(
              point: LatLng(me.latitude, me.longitude),
              width: 40,
              height: 40,
              child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
            ),
          );
        }
        if (partner != null) {
          markers.add(
            Marker(
              point: LatLng(partner.latitude, partner.longitude),
              width: 40,
              height: 40,
              child: const Icon(Icons.favorite, color: Colors.pink, size: 32),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Live Map'),
            actions: [
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  _mapController.move(center, 15);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (loc.error != null)
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.all(8),
                  child: Text(loc.error!),
                ),
              Consumer<AuthProvider>(builder: (context, auth, _) {
                if (auth.user?.partnerId == null) {
                  return Container(
                    width: double.infinity,
                    color: Colors.blueGrey.shade50,
                    padding: const EdgeInsets.all(8),
                    child: const Text('Connect with a partner to see their live location.'),
                  );
                }
                return const SizedBox.shrink();
              }),
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.circle, color: Colors.blue, size: 12),
                      const SizedBox(width: 6),
                      Text('Me: ${me != null ? '${me.latitude.toStringAsFixed(5)}, ${me.longitude.toStringAsFixed(5)}' : '—'}'),
                    ]),
                    Row(children: [
                      const Icon(Icons.favorite, color: Colors.pink, size: 12),
                      const SizedBox(width: 6),
                      Text('Partner: ${partner != null ? '${partner.latitude.toStringAsFixed(5)}, ${partner.longitude.toStringAsFixed(5)}' : '—'}'),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

