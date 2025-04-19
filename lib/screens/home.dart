import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Use relative imports since files are in the same directory
import 'profile.dart';
import 'mood_graph.dart';
import 'side_quests.dart';
import 'ai_chat.dart';
import 'settings.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key); // Added const constructor

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Made screens final and added const constructors
  final List<Widget> _children = [
    const ProfileScreen(),
    const MoodGraphScreen(),
    const SideQuestsScreen(),
    const AIChatScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Motivational quote
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _getDailyQuote(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,  // Better for quotes
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Mood tracking button
          Padding( // Added padding for better spacing
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => _showMoodDialog(context),
              child: const Text('How are you feeling?'),
            ),
          ),

          // Current screen content
          Expanded(
            child: _children[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [ // Made items const
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Mood'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Side Quest'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0: return 'Profile';
      case 1: return 'Mood Tracker';
      case 2: return 'Side Quests';
      case 3: return 'AI Companion';
      case 4: return 'Settings';
      default: return 'Mood Tracker';
    }
  }

  String _getDailyQuote() {
    // Consider making this a list of quotes if you want variety
    return "Every day may not be good, but there's something good in every day.";
  }

  Future<void> _showMoodDialog(BuildContext context) async {
    String? selectedMood;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Your Mood'),
        content: DropdownButtonFormField<String>(
          value: selectedMood,
          items: const [ // Made items const
            DropdownMenuItem(value: 'happy', child: Text('Happy 😊')),
            DropdownMenuItem(value: 'alright', child: Text('Alright 🙂')),
            DropdownMenuItem(value: 'neutral', child: Text('Neutral 😐')),
            DropdownMenuItem(value: 'angry', child: Text('Angry 😠')),
            DropdownMenuItem(value: 'sad', child: Text('Sad 😢')),
          ],
          onChanged: (value) => selectedMood = value,
          decoration: const InputDecoration(labelText: 'Select your mood'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedMood != null) {
                _saveMood(selectedMood!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar( // Added feedback
                  const SnackBar(content: Text('Mood saved successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMood(String mood) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('mood_entries').insert({
        'user_id': user.id,
        'mood': mood,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving mood: $e');
      // Consider showing an error message to the user
    }
  }
}