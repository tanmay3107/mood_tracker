// screens/profile.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key); // ✅ Added const constructor
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          SizedBox(height: 20),
          Text('Name: ${user?.userMetadata?['name'] ?? 'Not set'}'),
          Text('Email: ${user?.email ?? 'Not available'}'),
          // Add more profile info as needed
        ],
      ),
    );
  }
}