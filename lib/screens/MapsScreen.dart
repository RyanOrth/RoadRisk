import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});
  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  Marker _origin = const Marker(markerId: MarkerId("origin"), visible: false);
  Marker _destination =
      const Marker(markerId: MarkerId("destination"), visible: false);

  final LatLng _center = const LatLng(37.773972, -122.432917); // San Francisco

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        floatingActionButton: const FloatingActionButton(
          onPressed: null,
          tooltip: 'Help',
          child: Icon(Icons.add),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: {
            if (_origin.visible) _origin,
            if (_destination.visible) _destination,
          },
          onTap: _addMarker,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        )));
  }

  void _addMarker(LatLng pos) {
    if (!_origin.visible || (!_origin.visible && !_destination.visible)) {
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
          visible: true,
        );
        // Reset destination
        _destination =
            const Marker(markerId: MarkerId("destination"), visible: false);
      });
    } else {
      // Origin is already set
      // Set destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
          visible: true,
        );
      });
      /* 
      // Get directions
      final directions = await DirectionsRepository()
          .getDirections(origin: _origin.position, destination: pos);
      setState(() => _info = directions);
      */
    }
  }
}
