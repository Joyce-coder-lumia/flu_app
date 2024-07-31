import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:intl/intl.dart';
import 'package:covhealth/widgets/api_service.dart';
import 'package:covhealth/widgets/bot.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;

  const ChatPage({required this.conversationId, super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FlutterTts flutterTts = FlutterTts();
  List<ChatBubbleData> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isTyping = false;
  bool _showWelcomeMessage = true;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("fr-FR");
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

    setState(() {
      _isTyping = true;
      _showWelcomeMessage = false;
    });

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
        flutterTts.speak(response);
        _isTyping = false;

      });

      await _apiService.sendMessage(widget.conversationId, botMessage);
      print("Réponse du bot envoyée au backend");
    } catch (e) {
      setState(() {
        _messages.add(ChatBubbleData(message: 'Erreur: ${e.toString()}', isSender: false, timestamp: DateTime.now()));
        _isTyping = false;

      });
      print("Erreur lors de l'envoi du message ou de la réception de la réponse: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'CovhealthBot',
                style: TextStyle(fontSize: 18),
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
      body: MedicalChatScreen(
        conversationId: widget.conversationId,
        messages: _messages,
        onSendMessage: _sendMessage,
        controller: _controller,
        isTyping: _isTyping,
        showWelcomeMessage: _showWelcomeMessage,
      ),
    );
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
}

class MedicalChatScreen extends StatefulWidget {
  final String conversationId;
  final List<ChatBubbleData> messages;
  final VoidCallback onSendMessage;
  final TextEditingController controller;
  final bool isTyping;
  final bool showWelcomeMessage;

  const MedicalChatScreen({
    required this.conversationId,
    required this.messages,
    required this.onSendMessage,
    required this.controller,
    required this.isTyping,
    required this.showWelcomeMessage,
    Key? key,
  }) : super(key: key);

  @override
  _MedicalChatScreenState createState() => _MedicalChatScreenState();
}

class _MedicalChatScreenState extends State<MedicalChatScreen> {
  late List<ChatBubbleData> _messages = [];
  @override
  void initState() {
    super.initState();
    print('Incoming messages : ${widget.messages.map((m) => m.message).toList()}');
    _messages = widget.messages;
    print('Messages after initialization  : ${_messages.map((m) => m.message).toList()}');

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

    return Column(
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
                                      ? Color(0xFFE0A3F8)
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
                                backgroundImage: AssetImage('assets/images/profile.jpg'),
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
        if (widget.isTyping)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SpinKitThreeBounce(
              color: Colors.blueGrey,
              size: 30.0,
            ),
          ),
        if (widget.showWelcomeMessage) // Afficher le message de bienvenue si showWelcomeMessage est vrai
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText('Bienvenue sur CovhealthBot!'),
                  WavyAnimatedText('Posez vos questions médicales.'),
                ],
                isRepeatingAnimation: true,
              ),
            ),
          ),


        Padding(
          padding: const EdgeInsets.all(8.0),


          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
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
                  onPressed: widget.onSendMessage,
                ),
              ),
            ],
          ),

        ),


      ],
    );
  }
}



