// lib/models/mood_entry.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodEntry {
  final DateTime date;
  final String mood;
  final int moodValue;

  MoodEntry({
    required this.date,
    required this.mood,
    required this.moodValue,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['created_at']),
      mood: json['mood'],
      moodValue: _moodToValue(json['mood']),
    );
  }

  static int _moodToValue(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return 5;
      case 'alright': return 4;
      case 'neutral': return 3;
      case 'angry': return 2;
      case 'sad': return 1;
      default: return 3;
    }
  }

  Color get moodColor {
    switch (mood.toLowerCase()) {
      case 'happy': return Colors.green;
      case 'alright': return Colors.lightGreen;
      case 'neutral': return Colors.yellow;
      case 'angry': return Colors.red;
      case 'sad': return Colors.blue;
      default: return Colors.grey;
    }
  }
}