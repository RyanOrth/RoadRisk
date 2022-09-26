import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  LatLngBounds bounds;
  var polylinePoints;
  final String totalDistance;
  final String totalDuration;
  final String encodedPolyline;

  Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.encodedPolyline,
  });
}
