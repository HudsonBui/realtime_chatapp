import 'package:flutter/material.dart';
import 'package:realtime_chatapp/models/user_models.dart';
import 'package:realtime_chatapp/pages/widget/chatbox_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.user,super.key});
  final UserModel user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'User Name',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Active Time',
                  style: TextStyle(fontSize: 16),
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.videocam,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.info,
              size: 30,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(),
          ),
          const ChatBox(),
        ],
      ),
    );
  }
}
