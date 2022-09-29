import 'package:flutter/material.dart';
import 'package:road_risk/screens/MapsScreen.dart';
import 'package:road_risk/screens/RoutesScreen.dart';
import 'package:road_risk/screens/SettingsScreen.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_risk/models/routes_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Road Risk App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => RoutesModel(),
        child: const HomePage(title: 'Road Risk App Home Page'),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _selectedIndex = 0;
  bool hasNewRoute = false;
  // var screens = [
  //   const MapsScreen(
  //     addNewRoute: addNewRoute,
  //   ),
  //   const RoutesScreen(),
  //   const SettingsScreen()
  // ];

  void addNewRoute() {
    setState(() {
      //Write what you want to do here
      hasNewRoute = true;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1 && hasNewRoute) {
        hasNewRoute = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // child: screens[_selectedIndex],
        child: _selectedIndex == 0
            ? MapsScreen(addNewRoute: addNewRoute)
            : _selectedIndex == 1
                ? const RoutesScreen()
                : const SettingsScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Stack(children: <Widget>[
              const Icon(Icons.directions_car),
              Positioned(
                // draw a red marble
                top: 0.0,
                right: 0.0,
                child: Visibility(
                  visible: hasNewRoute,
                  child: const Icon(
                    Icons.brightness_1,
                    size: 8.0,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ]),
            label: 'Routes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
