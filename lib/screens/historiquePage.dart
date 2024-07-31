import 'package:flutter/material.dart';
import 'package:covhealth/widgets/api_service.dart';
import 'chatPage.dart';
import 'package:covhealth/widgets/bot.dart';
import 'converHistoriquePage.dart';


class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  final ApiService _apiService = ApiService();
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      List<Conversation> conversations = await _apiService.getConversations();
      setState(() {
        _conversations = conversations;
      });
    } catch (e) {
      print("Failed to load conversations: $e");
    }
  }

  void _continueConversation(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoverHistoPage(
          conversationId: conversation.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE8C4F6),
        title: Text('Historique'),
      ),
      body: _conversations.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          var conversation = _conversations[index];
          var messages = conversation.messages;
          return Card(
            child: ListTile(
              title: Text('Conversation ${index + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: messages.map<Widget>((message) {
                  bool isSender = message.isSender;
                  return ListTile(
                    leading: isSender ? Icon(Icons.person) : Icon(Icons.chat_bubble),
                    title: Text(message.message),
                    subtitle: Text(message.timestamp.toIso8601String()),
                  );
                }).toList(),
              ),
              onTap: () => _continueConversation(conversation),

            ),
          );
        },
      ),
    );
  }
}













