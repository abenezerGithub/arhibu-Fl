import 'dart:convert';

import 'package:arhibu/global_service/request_config.dart';
import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String? otherUserUid;
  const ChatDetailScreen({
    Key? key,
    this.otherUserUid,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage>? _messages;
  final Color _orangeColor = Colors.orange; // Define orange color
  final Color _lightOrange = Color(0xFFFFF3E0); // Light orange color

  @override
  void initState() {
    super.initState();
    _getChats(widget.otherUserUid ?? '');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final postMessage = await RequestConfig.securePost("/chat/new", {
        "message": _messageController.text,
        "receiverUid": widget.otherUserUid,
      });
      _getChats(widget.otherUserUid ?? '');
    } catch (err) {
      // Todo error handling
      rethrow;
    }

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<List<ChatMessage>> _getChats(String chatId) async {
    // Simulate fetching chats from a database or API
    try {
      print("Fetching chats for chatId: $chatId");
      final response = await RequestConfig.secureGet("/chat/" + chatId);
      final body = response.body;

      print(response);

      final chat = jsonDecode(body)["chat"] as List<dynamic>;
      final serializedChat = chat
          .map((e) {
            return ChatMessage(
              text: e['message'] ?? 'No message',
              isMe: e['senderUid'] != widget.otherUserUid,
              time: DateTime.tryParse(e['date']) != null
                  ? '${DateTime.parse(e['date']).hour % 12}:${DateTime.parse(e['date']).minute.toString().padLeft(2, '0')} ${DateTime.parse(e['date']).hour < 12 ? 'AM' : 'PM'}'
                  : 'Invalid date',
            );
          })
          .toList()
          .reversed
          .toList();
      setState(() {
        _messages = serializedChat;
      });
      return serializedChat;
    } catch (err) {
      // Todo error handling
      print(err);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: _messages == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _messages?.length == 0
                ? Center(
                    child: Text(
                      'No messages yet',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: _messages!.length,
                            itemBuilder: (context, index) {
                              final message = _messages![index];
                              return MessageBubble(
                                message: message,
                                lightOrange: _lightOrange,
                                orangeColor: _orangeColor,
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                top: BorderSide(color: Colors.grey.shade200)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: const InputDecoration(
                                      hintText: 'Type your message here...',
                                      border: InputBorder.none,
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundColor: _orangeColor,
                                child: IconButton(
                                  icon: const Icon(Icons.send,
                                      color: Colors.white),
                                  onPressed: _sendMessage,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color lightOrange;
  final Color orangeColor;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.lightOrange,
    required this.orangeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isMe ? lightOrange : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: message.isMe
                    ? Border.all(color: orangeColor.withOpacity(0.3))
                    : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isMe ? Colors.black : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
