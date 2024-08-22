import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final String lastMessage;
  final DateTime lastMessageTime;
  List<dynamic> participants;

  ChatModel({
    required this.chatId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.participants,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chat_id'] ?? '',
      lastMessage: map['last_message'] ?? '',
      lastMessageTime: (map['last_message_time'] as Timestamp).toDate(),
      participants: map['participants'] ?? [],
    );
  }
}
