import 'package:flutter_map/flutter_map.dart';
import 'package:road_risk/.env.dart';
import 'package:road_risk/models/directions_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:latlong2/latlong.dart';

final List<LatLng> newYork = [
  LatLng(40.4770030818, -74.2270386219),
  LatLng(40.4890150976, -74.2558777332),
  LatLng(40.5140767279, -74.2565643787),
  LatLng(40.5339105445, -74.2483246326),
  LatLng(40.5485211801, -74.2510712147),
  LatLng(40.5594770654, -74.2290985584),
  LatLng(40.5594770654, -74.2139923573),
  LatLng(40.6011973473, -74.2002594471),
  LatLng(40.6324704817, -74.2030060291),
  LatLng(40.6454966335, -74.1858398914),
  LatLng(40.6428916065, -74.1570007801),
  LatLng(40.6512273351, -74.0842163563),
  LatLng(40.6527901683, -74.0540039539),
  LatLng(40.780297958, -73.9990723133),
  LatLng(40.8883577346, -73.931094408),
  LatLng(40.9962413338, -73.8940155506),
  LatLng(41.0961872052, -74.1233551502),
  LatLng(41.2961392457, -73.5554993153),
  LatLng(41.2135457982, -73.4854614735),
  LatLng(41.1008441887, -73.7285339832),
  LatLng(41.0159317968, -73.6639893055),
  LatLng(40.9641021587, -73.5431396961),
  LatLng(41.2538231496, -72.0956909657),
  LatLng(41.0428671059, -71.7853271961),
  LatLng(40.4989364458, -73.4717285633),
  LatLng(40.5031134167, -74.056750536),
  LatLng(40.4770030818, -74.2270386219)
];

class DirectionsRepository {
  List<List<num>> polylineCoordinates = [];
  List<LatLng> polylineLatLongs = [];
  bool accurateRisk = true;

  bool _isPointInPolygon(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    LatLngBounds fastBoundsCheck = LatLngBounds.fromPoints(vertices);
    if (!fastBoundsCheck.contains(tap)) {
      return false;
    }

    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }
    return ((intersectCount & 1) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }

    return pY < aY != pY < bY && (pX < (bX - aX) * (pY - aY) / (bY - aY) + aX);
  }

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final httpResponse = await http.get(Uri.parse(
        'http://127.0.0.1:8000/Route/Origin=${origin.latitude},${origin.longitude}&Destination=${destination.latitude},${destination.longitude}'));

    accurateRisk = _isPointInPolygon(origin, newYork) &&
        _isPointInPolygon(destination, newYork);
    final result = jsonDecode(httpResponse.body.toString());
    if (result["totalDuration"] != 0) {
      result["decodedPolyline"].forEach((point) {
        polylineCoordinates.add([point[0], point[1]]);
        polylineLatLongs.add(LatLng(point[0], point[1]));
        // if (accurateRisk &&
        //     _isPointInPolygon(LatLng(point[0], point[1]), newYork)) {
        //   accurateRisk = false;
        // }
      });
      var tempDirections = Directions(
        polylinePoints: polylineLatLongs,
        totalDistance: result["totalDistance"].toDouble(),
        totalDuration: result["totalDuration"].toDouble(),
        encodedPolyline: result["polyline"],
        risk: result["risk"].toDouble(),
        accurateRisk: accurateRisk,
      );
      return tempDirections;
    } else {
      return null;
    }
  }
}
