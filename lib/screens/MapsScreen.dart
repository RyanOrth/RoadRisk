import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_risk/models/routes_model.dart';
import 'package:uuid/uuid.dart';
import 'package:road_risk/models/directions_model.dart';
import 'package:road_risk/common/directions_repository.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});
  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  var _markers = <Marker>{};
  var _polylines = <Polyline>{};
  final LatLng _center = const LatLng(37.773972, -122.432917); // San Francisco
  Directions? _info;

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
                LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0)),
            polylinePoints: _info?.polylinePoints,
            totalDistance: _info?.totalDistance ?? "",
            totalDuration: _info?.totalDuration ?? "",
            encodedPolyline: _info?.encodedPolyline ?? ""));
      }
      setState(() {});
    }

    return (Stack(
      children: [
        Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              label: Text("Add Route to Routes"),
              icon: Icon(Icons.add),
              onPressed: _addRouteToRoutes,
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
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Text("Text 1"), Text("Text 2")]),
              ),
            )),
      ],
    ));
  }

  void _addMarker(LatLng pos) async {
    if (_markers.isEmpty || (_markers.length == 2)) {
      setState(() {
        _markers = {};
      });
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(Uuid().v4()),
          infoWindow: const InfoWindow(title: "Origin"),
          draggable: true,
          position: pos,
        ));
        _info = null;
        _polylines = {};
        _polylines.add(Polyline(
          polylineId: PolylineId(Uuid().v4.toString()),
          points: [],
          width: 4,
          color: Colors.red,
        ));
      });
    } else {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(Uuid().v4()),
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
          polylineId: PolylineId(Uuid().v4.toString()),
          points: direction.polylinePoints,
          width: 4,
          color: Colors.red,
        ));
      });
    });
  }
}
