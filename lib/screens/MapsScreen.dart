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
  var _markers = <Marker>{};

  final LatLng _center = const LatLng(37.773972, -122.432917); // San Francisco

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _addMarkerToList,
          tooltip: 'Help',
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

  void _addMarker(LatLng pos) {
    if (_markers.isEmpty || (_markers.length == 2)) {
      setState(() {
        _markers = {};
      });
      setState(() {
        _markers.add(Marker(
          markerId: const MarkerId("origin"),
          infoWindow: const InfoWindow(title: "Origin"),
          draggable: true,
          position: pos,
        ));
      });
    } else {
      setState(() {
        _markers.add(Marker(
          markerId: const MarkerId("destination"),
          infoWindow: const InfoWindow(title: "Destination"),
          draggable: true,
          position: pos,
        ));
      });
    }
  }

  void _addMarkerToList() {
    setState(() {
      print(_markers);
      _markers = {};
      print(_markers);
    });
  }

  /*
  void _addMarker(LatLng pos) {
    if (!_origin.visible || (_origin.visible && _destination.visible)) {
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: LatLng(pos.latitude, pos.longitude),
          visible: true,
        );
        /*
        const position = pos;
        _origin = const Marker(
            markerId: MarkerId('origin'),
            infoWindow: InfoWindow(title: 'Destination'),
            position: position,
            visible: true);
        */
        _destination = const Marker(
            markerId: MarkerId('destination'),
            position: LatLng(0, 0),
            visible: false);
        print(pos);
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
  }*/
}
