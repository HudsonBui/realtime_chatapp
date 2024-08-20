import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realtime_chatapp/models/chat_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chats_provider.g.dart';

//TODO: Implement Messages Model, Chats Model
//TODO: Implement Caching and Pagination for chats and messages
@riverpod
class ChatNotifier extends _$ChatNotifier {
  //Initiate function
  @override
  Stream<List<ChatModel>> build() {
    //Get account id
    var uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future addNewChat(ChatModel chat) async {
    await FirebaseFirestore.instance.collection('chats').add({
      'participants': chat.participants,
      'last_message': chat.lastMessage as Timestamp,
      'last_message_time': chat.lastMessageTime,
    });
  }

  Future updateLastMessage(String lastMessage) async {
    await FirebaseFirestore.instance.collection('chats').doc().update({
      'last_message': lastMessage,
      'last_message_time': Timestamp.now(),
    });
  }
}
