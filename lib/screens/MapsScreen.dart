import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
//import 'package:road_risk/models/directions_model.dart';
//import 'package:road_risk/common/directions_repository.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});
  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  var _markers = <Marker>{};
  final LatLng _center = const LatLng(37.773972, -122.432917); // San Francisco
  //Directions? _info;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _addRouteToRoutes,
          tooltip: 'Add Route',
          child: const Text("+Route"), //Icon(Icons.add),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: _markers,
          onTap: _addMarker,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        )));
  }

  void _addMarker(LatLng pos) async {
    if (_markers.isEmpty || (_markers.length == 2)) {
      setState(() {
        _markers = {};
      });
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(Uuid().v1()),
          infoWindow: const InfoWindow(title: "Origin"),
          draggable: true,
          position: pos,
        ));
        //_info = null;
      });
    } else {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(Uuid().v1()),
          infoWindow: const InfoWindow(title: "Destination"),
          draggable: true,
          position: pos,
        ));
      });
    }
    /*
    // Get directions
    final directions = await DirectionsRepository()
        .getDirections(origin: _markers.first.position, destination: pos);
    setState(() => _info = directions);
    */
  }

  void _addRouteToRoutes() {
    setState(() {});
  }
}
