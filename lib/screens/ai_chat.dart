import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  String _currentMood = 'neutral'; // Track user's current mood
  bool _isLoading = false;

  Future<String> _getAIResponse(String message) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return "Please login to chat with the AI.";

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/chat'), // 10.0.2.2 for Android emulator
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken}'
        },
        body: jsonEncode({
          'message': message,
          'mood': _currentMood,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] && data['response'] != null) {
        return data['response'];
      } else {
        return "AI service is currently unavailable. Please try again later.";
      }
    } catch (e) {
      debugPrint('AI Chat Error: $e');
      return "Connection error. Please check your internet and try again.";
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty || _isLoading) return;

    final userMessage = ChatMessage(
      text: _messageController.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMessage);
      _messageController.clear();
    });

    final aiResponse = await _getAIResponse(userMessage.text);

    if (mounted) {
      setState(() {
        _messages.insert(0, ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mood),
            onPressed: () => _showMoodSelector(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.text,
                  isUser: message.isUser,
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoodSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Current Mood'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMoodButton('Happy', 'happy'),
            _buildMoodButton('Alright', 'alright'),
            _buildMoodButton('Neutral', 'neutral'),
            _buildMoodButton('Angry', 'angry'),
            _buildMoodButton('Sad', 'sad'),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(String label, String mood) {
    return TextButton(
      onPressed: () {
        setState(() => _currentMood = mood);
        Navigator.pop(context);
      },
      child: Text(label),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}