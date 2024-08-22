import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chatapp/enum/mess_status_enum.dart';
import 'package:realtime_chatapp/enum/mess_type_enum.dart';
import 'package:realtime_chatapp/models/message_model.dart';
import 'package:realtime_chatapp/providers/messages_provider.dart';

class ChatBox extends ConsumerStatefulWidget {
  const ChatBox(
      {required this.chatId, required this.participantsId, super.key});
  final String chatId;
  final List<String> participantsId;

  @override
  ConsumerState<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends ConsumerState<ChatBox> {
  final chatBoxController = TextEditingController();

  Future<void> sendMessage(WidgetRef ref) async {
    final message = chatBoxController.text;
    final senderId = FirebaseAuth.instance.currentUser!.uid;
    final dateTime = DateTime.now();
    const status = MessageStatusEnum.sent;
    const messType = MessageTypeEnum.text;
    if (message.trim().isEmpty) {
      return;
    }
    print('CHAT ID (addNewChat - chat_provider): ${widget.chatId}');
    //TODO: Implement the addMessage function from the messages_provider.dart
    ref.read(messagesNotifierProvider(widget.chatId).notifier).addMessage(
        MessageModel(
            message: message,
            messageType: messType,
            timestamp: dateTime,
            senderId: senderId,
            status: status),
        widget.chatId,
        widget.participantsId);
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
            onPressed: () async {
              await sendMessage(ref);
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
