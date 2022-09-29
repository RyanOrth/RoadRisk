import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_risk/models/routes_model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_map/flutter_map.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});
  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  void _showDialog(BuildContext context, title, secondaryText, bodyText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text("content"),
          actions: [
            MaterialButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: context.watch<RoutesModel>().savedRoutes.isEmpty
          ? const Text('Wow such empty!')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: context.watch<RoutesModel>().savedRoutes.length,
              itemBuilder: (BuildContext context, int index) {
                return createCard(
                  'Distance ${context.watch<RoutesModel>().savedRoutes[index].totalDistance}',
                  'Risk: ${context.watch<RoutesModel>().savedRoutes[index].risk}',
                  'Time: ${context.watch<RoutesModel>().savedRoutes[index].totalDuration}',
                  context
                      .watch<RoutesModel>()
                      .savedRoutes[index]
                      .encodedPolyline,
                  index,
                  context
                      .watch<RoutesModel>()
                      .savedRoutes[index]
                      .polylinePoints,
                  context,
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
    );
  }

  Widget createCard(
    title,
    secondaryText,
    bodyText,
    encodedPolyline,
    indexOfRouteInModel,
    polylinePoints,
    context,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.arrow_drop_down_circle),
            title: Text(title),
            subtitle: Text(
              secondaryText,
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          _buildMapImage(polylinePoints, context),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              bodyText,
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // Perform some action
                  _showDialog(context, title, secondaryText, bodyText);
                },
                child: const Text('Statistics'), //const Color(0xFF6200EE),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  onPressed: (() => {
                        Provider.of<RoutesModel>(context, listen: false)
                            .removeRouteAtIndex(indexOfRouteInModel)
                      }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapImage(polylinePoints, context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.80,
        height: MediaQuery.of(context).size.width * 0.35,
        child: FlutterMap(
          options: MapOptions(
            enableScrollWheel: false,
            center: polylinePoints[(polylinePoints.length / 2).round()],
            zoom: 8,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: polylinePoints,
                  color: Colors.red,
                  strokeWidth: 5,
                ),
              ],
            ),
          ],
        ));
  }
}
