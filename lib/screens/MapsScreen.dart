import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_risk/models/routes_model.dart';
import 'package:uuid/uuid.dart';
import 'package:road_risk/models/directions_model.dart';
import 'package:road_risk/common/directions_repository.dart';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MapsScreen extends StatefulWidget {
  final VoidCallback addNewRoute;

  const MapsScreen({super.key, required this.addNewRoute});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final mapController = MapController();

  /// List of the red pin markers that are dropped on the map
  ///
  /// Should only ever have one or two in the list, contains zero upon
  /// startup and when switching to the MapScreen
  var _markers = <Marker>[];

  /// List of lines that form the generated route
  var _polylines = <Polyline>[];

  /// Where the map opens to
  final LatLng _center = LatLng(40.7128, -73.8060); // New York City

  Directions? _info;

  bool _loadingRoute = false;

  /// Whether the mouse is currently over the add Routes button.
  /// Used for stopping dropping a pin below the button
  bool _hoveringOverAddButton = false;

  @override
  Widget build(BuildContext context) {
    /// Add generated route to list of saved routes
    void _addRouteToRoutes() {
      var routeModel = context.read<RoutesModel>();
      if (_info != null) {
        routeModel.addRoute(Directions(
          polylinePoints: _info?.polylinePoints,
          totalDistance: (_info?.totalDistance ?? 0),
          totalDuration: _info?.totalDuration ?? 0,
          encodedPolyline: _info?.encodedPolyline ?? "",
          risk: _info?.risk ?? 0,
          accurateRisk: _info?.accurateRisk ?? false,
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
          body: FlutterMap(
            options: MapOptions(
              center: _center,
              zoom: 10,
              onTap: _addMarker,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: newYork,
                    color: Color.fromARGB(82, 129, 253, 177),
                    borderColor: Colors.green,
                    isFilled: false,
                    borderStrokeWidth: 3,
                  )
                ],
              ),
              MarkerLayer(markers: _markers),
              PolylineLayer(
                polylines: _polylines,
              ),
            ],
          ),
        ),
        infoPill(),
        _loadingRoute
            ? const SpinKitFoldingCube(
                color: Colors.blue,
              )
            : Container(),
      ],
    ));
  }

  /// Widget at top of the screen
  ///
  /// Shows information about the generated route
  Widget infoPill() {
    return Positioned(
      top: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(left: 25, right: 25),
          constraints: const BoxConstraints(maxWidth: 700),
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
                  Text("${_info?.risk.toStringAsFixed(5) ?? "0"} Crashes/AADT"),
                  const VerticalDivider(),
                  Text("${_info?.totalDuration.toStringAsFixed(3) ?? "0"} Min"),
                  const VerticalDivider(),
                  Text("${_info?.totalDistance ?? "0"} Meters"),
                ]),
          ),
        ),
      ),
    );
  }

  /// Adds a marker at the given location.
  ///
  /// Will not add if mouse over add Route button. If two markers
  /// are down, they get removed and then the new one is placed at
  /// the selected new location.
  void _addMarker(tapPos, LatLng pos) async {
    if (_hoveringOverAddButton) {
      // Don't place marker under button when it's clicked
      return;
    }
    if (_markers.isEmpty || (_markers.length == 2)) {
      setState(() {
        _markers = [];
      });
      setState(() {
        _markers.add(
          Marker(
            point: pos,
            builder: (ctx) => GestureDetector(
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ),
        );
        _info = null;
        _polylines = [];
      });
    } else {
      setState(() {
        _markers.add(
          Marker(
            point: pos,
            builder: (ctx) => GestureDetector(
              child:
                  const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ),
        );
        _loadingRoute = true;
      });
    }

    var directions = await DirectionsRepository()
        .getDirections(origin: _markers.first.point, destination: pos);
    if (directions != null) {
      setState(() {
        _info = directions;
        _polylines = [];
        _polylines.add(Polyline(
          points: directions?.polylinePoints,
          color: Colors.red,
          strokeWidth: 3,
        ));
        _loadingRoute = false;
      });
    }
  }
}
