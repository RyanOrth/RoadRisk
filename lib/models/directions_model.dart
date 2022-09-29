class Directions {
  //LatLngBounds bounds;
  var polylinePoints;
  final double totalDistance;
  final double totalDuration;
  final String encodedPolyline;
  final double risk;
  final bool accurateRisk;

  Directions({
    //required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.encodedPolyline,
    required this.risk,
    required this.accurateRisk,
  });
}
