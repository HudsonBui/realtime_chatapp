import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime_chatapp/models/chat_model.dart';
import 'package:realtime_chatapp/models/message_model.dart';
import 'package:realtime_chatapp/providers/chats_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages_provider.g.dart';

//TODO: Implement Messages Model, Chats Model
//TODO: Implement Caching and Pagination for chats and messages
@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  //Initiate value
  @override
  Stream<List<MessageModel>> build(String chatId) {
    print('CHAT ID (build - messages_provider): $chatId');
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      },
    );
  }

  //update function
  Future addMessage(
      MessageModel message, String chatId, List<String> participants) async {
    //TODO: implement addNewChat function
    await ref.read(chatNotifierProvider.notifier).addNewChat(
          ChatModel(
              chatId: chatId,
              lastMessage: message.message,
              lastMessageTime: message.timestamp,
              participants: participants),
        );
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'message': message.message,
      'sender_id': message.senderId,
      'timestamp': message.timestamp,
      'status': message.status.toString().split('.').last,
      'message_type': message.messageType.toString().split('.').last,
    });
  }
}
//this is the thockiest keyboard
