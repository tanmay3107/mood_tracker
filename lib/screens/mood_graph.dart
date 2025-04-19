// lib/screens/mood_graph.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mood_entry.dart';

class MoodGraphScreen extends StatefulWidget {
  const MoodGraphScreen({Key? key}) : super(key: key);

  @override
  State<MoodGraphScreen> createState() => _MoodGraphScreenState();
}

class _MoodGraphScreenState extends State<MoodGraphScreen> {
  List<MoodEntry> _moodData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoodData();
  }

  Future<void> _fetchMoodData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('mood_entries')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(7);

    if (response != null && response.isNotEmpty) {
      setState(() {
        _moodData = response.map((entry) => MoodEntry.fromJson(entry)).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Your Mood Last Week',
            style: Theme.of(context).textTheme.titleLarge, // Updated from headline5
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _moodData.map((entry) {
                      return FlSpot(
                        entry.date.day.toDouble(),
                        entry.moodValue.toDouble(),
                      );
                    }).toList(),
                    color: Colors.blue,
                    barWidth: 4,
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString());
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        String text;
                        switch (value.toInt()) {
                          case 1:
                            text = 'Sad';
                            break;
                          case 2:
                            text = 'Angry';
                            break;
                          case 3:
                            text = 'Neutral';
                            break;
                          case 4:
                            text = 'Alright';
                            break;
                          case 5:
                            text = 'Happy';
                            break;
                          default:
                            text = '';
                        }
                        return Text(text);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}