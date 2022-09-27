import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'directions_model.dart';

class RoutesModel extends ChangeNotifier {
  List<Directions> routes = [];

  List<Directions> get savedRoutes => routes;

  void addRoute(route) {
    routes.add(route);
    notifyListeners();
  }

  void removeRouteAtIndex(indexToRemoveAt) {
    print(indexToRemoveAt);
    print(routes);
    routes.removeAt(indexToRemoveAt);
    notifyListeners();
  }
}
