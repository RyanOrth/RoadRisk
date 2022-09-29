import 'package:road_risk/.env.dart';
import 'package:road_risk/models/directions_model.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DirectionsRepository {
  List<List<num>> polylineCoordinates = [];
  List<LatLng> polylineLatLongs = [];

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final httpResponse = await http.get(Uri.parse(
        'http://127.0.0.1:8000/Route/Origin=${origin.latitude},${origin.longitude}&Destination=${destination.latitude},${destination.longitude}'));
    final result = jsonDecode(httpResponse.body.toString());
    if (result["totalDuration"] != 0) {
      result["decodedPolyline"].forEach((point) {
        polylineCoordinates.add([point[0], point[1]]);
        polylineLatLongs.add(LatLng(point[0], point[1]));
      });
      var tempDirections = Directions(
        polylinePoints: polylineLatLongs,
        totalDistance: result["totalDistance"],
        totalDuration: result["totalDuration"],
        encodedPolyline: result["polyline"],
        risk: result["risk"],
      );
      return tempDirections;
    } else {
      return null;
    }
  }
}
