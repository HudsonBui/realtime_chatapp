import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime_chatapp/enum/mess_status_enum.dart';
import 'package:realtime_chatapp/enum/mess_type_enum.dart';

class MessageModel {
  final String message;
  final MessageTypeEnum messageType;
  final DateTime timestamp;
  final String senderId;
  final MessageStatusEnum status;

  MessageModel({
    required this.message,
    required this.messageType,
    required this.timestamp,
    required this.senderId,
    required this.status,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      message: map['message'] ?? '',
      messageType: MessageTypeEnum.values.firstWhere((e) {
        return e.toString().split('.').last == map['message_type'];
      }, orElse: () => MessageTypeEnum.text),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      senderId: map['sender_id'] ?? '',
      status: MessageStatusEnum.values.firstWhere((e) {
        return e.toString().split('.').last == map['status'];
      }, orElse: () => MessageStatusEnum.failed),
    );
  }
}
