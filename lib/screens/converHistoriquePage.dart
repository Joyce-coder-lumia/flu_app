import 'package:flutter/material.dart';
import 'package:covhealth/widgets/api_service.dart';
import 'package:covhealth/widgets/bot.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

import 'chatPage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';



class CoverHistoPage extends StatefulWidget {
  final String conversationId;

  const CoverHistoPage({required this.conversationId, Key? key}) : super(key: key);

  @override
  State<CoverHistoPage> createState() => _CoverHistoPageState();
}

class _CoverHistoPageState extends State<CoverHistoPage> {
  List<ChatBubbleData> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  final FlutterTts flutterTts = FlutterTts();


  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("fr-FR");

    _loadConversation();
  }

  void _loadConversation() async {
    try {
      print("Chargement de la conversation...");
      final conversation = await _apiService.getConversation(widget.conversationId);
      setState(() {
        _messages = conversation.messages;
        print('Messages chargés: $_messages');
      });
    } catch (e) {
      print('Erreur lors du chargement de la conversation: $e');
    }
  }



  void _speak(String text) async {
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void _stop() async {
    await flutterTts.stop();
  }

  void _sendMessage() async {
    final input = _controller.text;
    if (input.isEmpty) return;

    final message = ChatBubbleData(
      message: input,
      isSender: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      print("Message envoyé: $input");
    });

    _controller.clear();

    try {
      await _apiService.sendMessage(widget.conversationId, message);

      final response = await _apiService.getMedicalResponse(input);
      print("Réponse du bot obtenue: $response");

      final botMessage = ChatBubbleData(
        message: response,
        isSender: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(botMessage);
      });

      await _apiService.sendMessage(widget.conversationId, botMessage);
      print("Réponse du bot envoyée au backend");
    } catch (e) {
      setState(() {
        _messages.add(ChatBubbleData(message: 'Erreur: ${e.toString()}', isSender: false, timestamp: DateTime.now()));
      });
      print("Erreur lors de l'envoi du message ou de la réception de la réponse: $e");
    }
  }

  String formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp).inDays;

    if (difference == 0) {
      return 'Aujourd\'hui';
    } else if (difference == 1) {
      return 'Hier';
    } else {
      return DateFormat('dd MMM yyyy').format(timestamp);
    }
  }

  String formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    print('Messages in build premier: ${_messages.map((m) => m.message).toList()}');

    Map<String, List<ChatBubbleData>> groupedMessages = {};
    for (var message in _messages) {
      String date = formatDate(message.timestamp);
      if (groupedMessages[date] == null) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(message);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFAA9DFA),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/bot.png'),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'CovhealthBot',
                style: TextStyle(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: Colors.black),
            onPressed: () {
              if (_messages.isNotEmpty) {
                _speak(_messages.last.message);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.stop, color: Colors.black),
            onPressed: _stop,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: groupedMessages.keys.length,
              itemBuilder: (context, index) {
                String date = groupedMessages.keys.elementAt(index);
                List<ChatBubbleData> messages = groupedMessages[date]!;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        date,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    ...messages.map((message) {
                      final formattedTime = formatTime(message.timestamp);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!message.isSender)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage('assets/images/bot.png'),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: message.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  BubbleSpecialThree(
                                    text: message.message,
                                    isSender: message.isSender,
                                    color: message.isSender
                                        ? Color(0xFFE0A3F8).withOpacity(0.5)
                                        : Color(0xFF3214EA).withOpacity(0.5),
                                    tail: true,
                                    textStyle: TextStyle(color: Colors.white),
                                    seen: true,
                                    delivered: true,
                                  ),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            if (message.isSender)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage('assets/sender_avatar.png'),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre question médicale...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD062FA),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



}
