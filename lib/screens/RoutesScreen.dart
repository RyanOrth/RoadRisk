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

/// Contains popup for information about the inherint statistics
class _RoutesScreenState extends State<RoutesScreen> {
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Info About Statistics"),
          content: const Text(
              "All distances are in meters, all times are in minutes, and all risk is in crashes per AADT. AADT stands for Annual Average Daily Traffic. AADT was needed to normalize the risk for each part of the path traveled over as this is a common way to normalize crash risk against the amount of people exposed to the risk. Data isn't directly retrieved from each road but is binned into squares for easier access. There is also an adjustment to the risk score based on the time of day you are driving."),
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

  /// Contains popup for showing user why risk may be inaccurate
  void _showDialogWarningMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Info About Risk"),
          content: const Text(
            'This is not in the know risk area and shown risk is a wild guess', // TODO: CHANGE this text
          ),
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    "Wow, such empty!",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Icon(
                    Icons.rocket_launch,
                    size: 64,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: context.watch<RoutesModel>().savedRoutes.length,
              itemBuilder: (BuildContext context, int index) {
                return createCard(
                  "Saved Route ${index + 1}",
                  'Of ${context.watch<RoutesModel>().savedRoutes.length}',
                  context.watch<RoutesModel>().savedRoutes[index].totalDistance,
                  context.watch<RoutesModel>().savedRoutes[index].totalDuration,
                  context.watch<RoutesModel>().savedRoutes[index].risk,
                  context.watch<RoutesModel>().savedRoutes[index].accurateRisk,
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
    distance,
    duration,
    risk,
    accurateRisk,
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
            leading: risk >= 0.01 // TODO: get gud numbers for these
                ? const Icon(
                    Icons.report,
                    color: Colors.red,
                  )
                : risk >= 0.005
                    ? Icon(
                        Icons.warning,
                        color: Colors.orange.shade300,
                      )
                    : const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
            title: Text(title),
            subtitle: Text(
              secondaryText,
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          // work on correct zoom -Past Garrett
          _buildMapImage(polylinePoints, context),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Text(
                'Distance: $distance meters',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.9), fontSize: 20),
              ),
              const Divider(),
              Text(
                'Duration: ${duration.toStringAsFixed(3)} min',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.9), fontSize: 20),
              ),
              const Divider(),
              accurateRisk
                  ? Text(
                      'Risk: ${risk.toStringAsFixed(5)} crashes annually per AADT',
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.9), fontSize: 20),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(
                                Icons.warning,
                                color: Colors.amber.shade300,
                              ),
                              onPressed: () =>
                                  _showDialogWarningMessage(context),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Risk: ${risk.toStringAsFixed(5)} crashes annually per AADT',
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.9),
                                fontSize: 20),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(),
                        ),
                      ],
                    ),
            ]),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // Perform some action
                  _showDialog(context);
                },
                child: const Text('Info About Statistics'),
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
