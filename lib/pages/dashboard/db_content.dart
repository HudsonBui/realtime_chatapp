import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime_chatapp/screen/chat_screen.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  var userId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> getFriendInfor(userId) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('friends').get();
    var allRelationship = querySnapshot.docs.map((e) => e.data()).toList();
    var friendInfor = allRelationship.where((element) => element['userID1'] == userId || element['userID2'] == userId).toList();
    return friendInfor;
  }

  //TODO: Get conversation
  Future<List<Map<String, dynamic>>> getConversation(userId) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('friends').get();
    var allRelationship = querySnapshot.docs.map((e) => e.data()).toList();
    var friendInfor = allRelationship.where((element) => element['userID1'] == userId || element['userID2'] == userId).toList();
    return friendInfor;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: GestureDetector(
            onTap: () {
              print('Menu button pressed');
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              print('Search button pressed');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search,
                    color: Colors.black38,
                  ),
                  Text(
                    'Search',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade100),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //TODO: Get user name!!!!!!!!
                      Container(
                        height: 70,
                        width: 70, // Adjust width as needed
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'Item $index',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Text('Item $index'),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const ChatScreen()));
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Content'),
                                      Text('Date'),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
