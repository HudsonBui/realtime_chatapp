import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chatapp/models/user_models.dart';
import 'package:realtime_chatapp/pages/widget/chatbox_widget.dart';
import 'package:realtime_chatapp/pages/widget/message_bubble.dart';
import 'package:realtime_chatapp/providers/messages_provider.dart';
import 'package:realtime_chatapp/providers/user_provider.dart';
import 'package:realtime_chatapp/screen/call_screen/call_holding_screen.dart';
import 'package:realtime_chatapp/screen/call_screen/video_call_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen(
      {required this.participantsId, required this.chatId, super.key});
  //TODO: passing more arguments: Me, Friend, chatId
  final List<String> participantsId;
  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  var authenticatedUser = FirebaseAuth.instance.currentUser;
  UserModel? otherUser;
  UserModel? me;

  @override
  Widget build(BuildContext context) {
    var messagesProvider = ref.watch(messagesNotifierProvider(widget.chatId));
    var userProvider =
        ref.read(userDetailProvider).getUsersInformation(widget.participantsId);

    //print('CHAT ID (chat_screen.dart): ${widget.participantsId}');
    final theme = Theme.of(context);
    return FutureBuilder(
        future: userProvider,
        builder: (ctx, snp) {
          if (snp.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox.shrink(),
            );
          }
          if (snp.hasData && snp.data != null) {
            me = snp.data![0].uid == authenticatedUser!.uid
                ? snp.data![0]
                : snp.data![1];
            otherUser = snp.data![0].uid != authenticatedUser!.uid
                ? snp.data![0]
                : snp.data![1];

            var useStatusProvider =
                ref.read(userDetailProvider).getUserActiveTime(otherUser!.uid);
            return Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: AppBar(
                backgroundColor: Colors.grey.shade200,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    otherUser!.photoUrl != ''
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              otherUser!.photoUrl,
                            ),
                            backgroundColor:
                                theme.colorScheme.primary.withAlpha(180),
                            radius: 23,
                          )
                        : ClipOval(
                            child: Container(
                              height: 46,
                              width: 46,
                              color: Colors.blue.shade600,
                              child: Center(
                                child: Text(
                                    otherUser!.fName
                                        .toString()
                                        .split(' ')
                                        .last
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 30)),
                              ),
                            ),
                          ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${otherUser!.fName} ${otherUser!.lName}',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.fade,
                        ),
                        FutureBuilder(
                            future: useStatusProvider,
                            builder: (ctx1, snp1) {
                              if (snp1.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...');
                              }
                              if (snp1.hasData && snp1.data != null) {
                                return Text(
                                  snp1.data.toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                              return const Text('Error fetching user status');
                            }),
                      ],
                    )
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.call,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (cxt) {
                            return VideoCallScreen(
                              participants: snp.data!,
                              chatId: widget.chatId,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.videocam,
                      size: 25,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.info,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: messagesProvider.when(
                      data: (messages) {
                        return messages != []
                            ? ListView.builder(
                                itemCount: messages.length,
                                reverse: true,
                                itemBuilder: (context, index) {
                                  var currentMessage = messages[index];
                                  var nextMessage = index + 1 < messages.length
                                      ? messages[index + 1]
                                      : null;
                                  var isTheSameUser = currentMessage.senderId ==
                                      nextMessage?.senderId;
                                  var isMe = currentMessage.senderId ==
                                      authenticatedUser!.uid;
                                  if (isTheSameUser) {
                                    return MessageBubble.next(
                                      message: currentMessage.message,
                                      isMe: isMe,
                                    );
                                  } else {
                                    if (isMe) {
                                      return MessageBubble.first(
                                        message: currentMessage.message,
                                        isMe: isMe,
                                        userImage: me!.photoUrl,
                                        username: me!.fName,
                                      );
                                    } else {
                                      return MessageBubble.first(
                                        message: currentMessage.message,
                                        isMe: isMe,
                                        userImage: otherUser!.photoUrl,
                                        username: otherUser!.fName,
                                      );
                                    }
                                  }
                                })
                            : const Center(
                                child: Text('Start conversation! ❤️'));
                      },
                      error: (error, stack) =>
                          Center(child: Text(error.toString())),
                      loading: () {
                        //TODO: Find out how to eliminate CircularProgressIndicator() from the screen + Implement cache for messages
                        return const Center(
                          child: SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                  ChatBox(
                      chatId: widget.chatId,
                      participantsId: widget.participantsId),
                ],
              ),
            );
          }
          return const Center(
            child: Text('Error fetching user data'),
          );
        });
  }
}
