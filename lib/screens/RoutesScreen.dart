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
          return Container(
            height: 50,
            color: Color.fromARGB(255, 83, 160, 83),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Route ${routeList[index]}',
                    style: _biggerFont,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('Risk: ${riskList[index]}'),
                  ),
                ),
                Expanded(
                  child: Text('time: ${timeSheet[index]}'),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
