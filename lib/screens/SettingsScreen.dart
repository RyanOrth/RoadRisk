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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
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
        ],
      ),
    );
  }
}
