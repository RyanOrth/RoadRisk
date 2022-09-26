import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_risk/models/routes_model.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});
  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  int randomNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: context.watch<RoutesModel>().savedRoutes.length,
        itemBuilder: (BuildContext context, int index) {
          return createCard(
            'Distance ${context.watch<RoutesModel>().savedRoutes[index].totalDistance}',
            'Risk: ${context.watch<RoutesModel>().savedRoutes[index].totalDistance}',
            'Time: ${context.watch<RoutesModel>().savedRoutes[index].totalDuration}',
            context.watch<RoutesModel>().savedRoutes[index].encodedPolyline,
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}

Widget createCard(
  title,
  secondaryText,
  bodyText,
  polyline,
) {
  return Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        ListTile(
          leading: Icon(Icons.arrow_drop_down_circle),
          title: Text(title),
          subtitle: Text(
            secondaryText,
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ),
        _buildStaticMapImage(polyline),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            bodyText,
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                // Perform some action
              },
              child: const Text('ACTION 1'), //const Color(0xFF6200EE),
            ),
            TextButton(
              onPressed: () {
                // Perform some action
              },
              child: const Text('ACTION 2'), //const Color(0xFF6200EE),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildStaticMapImage(path) {
  //var path = 'c``pEtjypUi@fAu@zA[j@mAzB';
  print(path);
  return FadeInImage(
    image: NetworkImage(
        'https://maps.googleapis.com/maps/api/staticmap?&type=roadmap&size=1080x720&path=color:red%7Cenc:${path}&key=AIzaSyAExn3Qa217QIG0it7y5KwFWWPkJmTgcF4'),
    placeholder:
        const AssetImage('images/circular_progress_indicator_square_small.gif'),
  );
}
