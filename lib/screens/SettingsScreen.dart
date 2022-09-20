import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settingsCount = 3;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: settingsCount,
        padding: const EdgeInsets.all(24),
        itemBuilder: (BuildContext context, int index) {
          return (Row(
            children: [
              Text(
                'Settings ',
              ),
              Switch(
                value: true,
                onChanged: (l) => {print("banana ${l}")},
              )
            ],
          ));
        },
      ),
    );
  }
}
