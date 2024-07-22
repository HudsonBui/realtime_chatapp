import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final chatBoxController = TextEditingController();

  void sendMessage() async {
    final message = chatBoxController.text;
    if (message.trim().isEmpty) {
      return;
    }
    await FirebaseFirestore.instance.collection('chat').add({
      'sender': 'senderUID',
      'receiver': 'receirverUID',
    });
    //TODO: Collect the receiver's UID from the chat screen.
    //TODO: Send the message to the receiver's UID.
    chatBoxController.clear();
  }

  @override
  void dispose() {
    chatBoxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: chatBoxController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  hintText: 'Message',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
