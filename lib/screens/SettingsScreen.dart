import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settingsCount = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50, left: 50, right: 50),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Maps Screen",
              style: TextStyle(
                fontSize: 40,
                color: Colors.blueGrey,
              ),
            ),
            Divider(),
            SizedBox(height: 40),
            Text(
              "When starting the app, navigate to the maps page and select two points on the map by tapping the desired locations.",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 35, 42, 46),
              ),
            ),
            SizedBox(height: 40),
            Image(
              image: AssetImage('lib/assets/mapsPage.png'),
              width: 500,
            ),
            SizedBox(height: 40),
            Text(
              "After waiting for the path and statistics to load, all should be available in the info pill on the top of the maps page.",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 35, 42, 46),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "When a route is interesting to you, you can add it to the saved routes page by clicking the 'Add Routes To Route' button",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 35, 42, 46),
              ),
            ),
            SizedBox(height: 40),
            Image(
              image: AssetImage('lib/assets/addRouteButton.png'),
              width: 500,
            ),
            SizedBox(height: 80),
            Text(
              "Routes Screen",
              style: TextStyle(
                fontSize: 40,
                color: Colors.blueGrey,
              ),
            ),
            Divider(),
            SizedBox(height: 40),
            Text(
              "In the routes, page you can look through your saved routes and compare tradeoffs between time, distance, and risk. There will also be notifiers about the validity of the risk for a given route shown below.",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 35, 42, 46),
              ),
            ),
            SizedBox(height: 40),
            Image(
              image: AssetImage('lib/assets/invalidRiskWarning.png'),
              width: 500,
            ),
            SizedBox(height: 40),
            Text(
              "You can also click the notifier on the top left of the card and see the specific category your risk falls into.",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 35, 42, 46),
              ),
            ),
            SizedBox(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image(
                image: AssetImage('lib/assets/badRisk.png'),
                width: 300,
              ),
              Image(
                image: AssetImage('lib/assets/riskAmountPopup.png'),
                width: 200,
              ),
            ]),
            SizedBox(height: 80),
            Divider(),
            Text(
              "Enjoy Our App!",
              style: TextStyle(
                fontSize: 40,
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
