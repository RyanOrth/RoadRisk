import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});
  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

final List<String> routeList = <String>['A', 'B', 'C'];
final List<double> riskList = <double>[0.5, 0.1, 0.4];
final List<int> timeSheet = <int>[10, 23, 1];

class _RoutesScreenState extends State<RoutesScreen> {
  final _biggerFont = const TextStyle(fontSize: 24);

  final int min = 0;
  final int max = 10;
  int randomNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          return (ExpansionTile(
            title: Text(
              'Route ${routeList[index]}',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            children: <Widget>[
              ListTile(
                title: Text(
                  'Risk: ${riskList[index]}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                title: Text(
                  'Time: ${timeSheet[index]}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ));
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
