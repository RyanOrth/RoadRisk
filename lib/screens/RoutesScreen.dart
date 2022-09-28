import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:road_risk/models/routes_model.dart';
import 'package:flutter_html/flutter_html.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});
  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

const htmlData = r"""
<p id='top'><a href='#'>This is the Link</a></p>
  
      <h1>Header 1</h1>
      <h2>Header 2</h2>
      <h3>Header 3</h3>
      <h4>Header 4</h4>
      <h5>Header 5</h5>
      <h6>Header 6</h6>
      <h3>This is HTML page that we want to integrate with Flutter.</h3>
       
""";

class _RoutesScreenState extends State<RoutesScreen> {
  int randomNumber = 1;

  void _showDialog(BuildContext context, title, secondaryText, bodyText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Html(
            data: htmlData,
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
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: context.watch<RoutesModel>().savedRoutes.length,
        itemBuilder: (BuildContext context, int index) {
          return createCard(
            'Distance ${context.watch<RoutesModel>().savedRoutes[index].totalDistance}',
            'Risk: ${context.watch<RoutesModel>().savedRoutes[index].risk}',
            'Time: ${context.watch<RoutesModel>().savedRoutes[index].totalDuration}',
            context.watch<RoutesModel>().savedRoutes[index].encodedPolyline,
            index,
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }

  Widget createCard(
    title,
    secondaryText,
    bodyText,
    polyline,
    indexOfRouteInModel,
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
          _buildStaticMapImage(polyline),
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

  Widget _buildStaticMapImage(path) {
    return FadeInImage(
      image: NetworkImage(
          'https://maps.googleapis.com/maps/api/staticmap?&type=roadmap&size=1580x520&path=color:red%7Cenc:${path}&key=AIzaSyAExn3Qa217QIG0it7y5KwFWWPkJmTgcF4'),
      placeholder: const AssetImage(
          'images/circular_progress_indicator_square_small.gif'),
    );
  }
}
