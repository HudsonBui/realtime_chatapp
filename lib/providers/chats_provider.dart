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
    //print('USER ID (build - chat_provider): $uid');
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
    var isExisten = false;
    var docSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.chatId)
        .get();
    isExisten = docSnapshot.exists;
    print('CHECK ISEXISTEN (addNewChat - chat_provider): $isExisten');
    print('CHAT ID (addNewChat - chat_provider): ${chat.chatId}');
    print('DOC DATA (addNewChat - chat_provider): ${docSnapshot.data()}');
    if (isExisten) {
      updateLastMessage(chat);
      print('UPDATE CHAT SUCCESSFULLY (addNewChat - chat_provider)');
      return;
    } else {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chat.chatId)
          .set({
        'chat_id': chat.chatId,
        'participants': chat.participants,
        'last_message': chat.lastMessage,
        'last_message_time': Timestamp.fromDate(chat.lastMessageTime),
      }, SetOptions(merge: true));
    }
    print('ADD CHAT SUCCESSFULLY (addNewChat - chat_provider)');
  }

  Future updateLastMessage(ChatModel chat) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.chatId)
        .update({
      'last_message': chat.lastMessage,
      'last_message_time': Timestamp.fromDate(chat.lastMessageTime),
    });
  }
}
