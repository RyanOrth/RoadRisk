import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_risk/models/routes_model.dart';
import 'package:uuid/uuid.dart';
import 'package:road_risk/models/directions_model.dart';
import 'package:road_risk/common/directions_repository.dart';
import 'dart:math';
// import 'dart:html' as html;
// import 'package:flutter/rendering.dart';

class MapsScreen extends StatefulWidget {
  final VoidCallback addNewRoute;

  const MapsScreen({super.key, required this.addNewRoute});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  var _markers = <Marker>{};
  var _polylines = <Polyline>{};
  final LatLng _center = const LatLng(40.7128, -73.8060); // New York City
  Directions? _info;
  bool _hoveringOverAddButton = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    void _addRouteToRoutes() {
      var routeModel = context.read<RoutesModel>();
      if (_info != null) {
        routeModel.addRoute(Directions(
          bounds: _info?.bounds ??
              LatLngBounds(
                  southwest: const LatLng(0, 0), northeast: const LatLng(0, 0)),
          polylinePoints: _info?.polylinePoints,
          totalDistance: (_info?.totalDistance ?? 0),
          totalDuration: _info?.totalDuration ?? 0,
          encodedPolyline: _info?.encodedPolyline ?? "",
          risk: _info?.risk ?? 0,
        ));
      }
      // setState(() {
      //   _markers = {};
      //   _polylines = {};
      // });
      if (_markers.length == 2 && _polylines.isNotEmpty) {
        widget.addNewRoute();
      }
      setState(() {});
    }

    return (Stack(
      children: [
        Scaffold(
            floatingActionButton: Container(
              width: 200,
              height: 200,
              child: Center(
                // For telling if mouse is on the button
                child: MouseRegion(
                  onEnter: (context) =>
                      setState(() => _hoveringOverAddButton = true),
                  onExit: (context) =>
                      setState(() => _hoveringOverAddButton = false),
                  child: FloatingActionButton.extended(
                    label: const Text("Add Route to Routes"),
                    icon: const Icon(Icons.add),
                    onPressed: _addRouteToRoutes,
                  ),
                ),
              ),
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
              polylines: _polylines,
            )),
        Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(left: 50, right: 50),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: Offset.zero),
                    ]),
                child: IntrinsicHeight(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Risk: ${_info?.risk ?? "0"}"),
                        const VerticalDivider(),
                        Text(
                            "Time: ${_info?.totalDuration.toStringAsFixed(3) ?? "0"} Min"),
                        const VerticalDivider(),
                        Text("Distance: ${_info?.totalDistance ?? "0"} Meters"),
                      ]),
                ),
              ),
            )),
      ],
    ));
  }

  void _addMarker(LatLng pos) async {
    if (_hoveringOverAddButton) {
      // Don't place marker under button when it's clicked
      return;
    }
    if (_markers.isEmpty || (_markers.length == 2)) {
      setState(() {
        _markers = {};
      });
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(const Uuid().v4()),
          infoWindow: const InfoWindow(title: "Origin"),
          draggable: true,
          position: pos,
        ));
        _info = null;
        _polylines = {};
        _polylines.add(Polyline(
          polylineId: PolylineId(const Uuid().v4.toString()),
          points: [],
          width: 4,
          color: Colors.red,
        ));
      });
    } else {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(const Uuid().v4()),
          infoWindow: const InfoWindow(title: "Destination"),
          draggable: true,
          position: pos,
        ));
      });
    }
    /*
    // Get directions
    */
    Future directions = DirectionsRepository()
        .getDirections(origin: _markers.first.position, destination: pos);
    directions.then((direction) {
      setState(() {
        _info = direction;
        _polylines = {};
        _polylines.add(Polyline(
          polylineId: PolylineId(const Uuid().v4.toString()),
          points: direction.polylinePoints,
          width: 4,
          color: Colors.red,
        ));
      });
    });
  }
}
