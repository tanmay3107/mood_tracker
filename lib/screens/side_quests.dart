// lib/screens/side_quests.dart
import 'package:flutter/material.dart';

class SideQuestsScreen extends StatefulWidget {
  const SideQuestsScreen({super.key});

  @override
  State<SideQuestsScreen> createState() => _SideQuestsScreenState();
}

class _SideQuestsScreenState extends State<SideQuestsScreen> {
  final List<Map<String, dynamic>> _quests = [
    {'title': 'Meditate for 5 minutes', 'completed': false},
    {'title': 'Write in journal', 'completed': false},
    {'title': 'Drink 8 glasses of water', 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _quests.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(_quests[index]['title']),
          value: _quests[index]['completed'],
          onChanged: (value) {
            setState(() {
              _quests[index]['completed'] = value;
            });
          },
        );
      },
    );
  }
}