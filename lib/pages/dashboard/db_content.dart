import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:realtime_chatapp/screen/chat_screen.dart';
import 'package:realtime_chatapp/services/user_status_services.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  var userId = FirebaseAuth.instance.currentUser!.uid;

  //Take the all Relationship of the current user
  Future<List<Map<String, dynamic>>> getRelationship() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('friends').get();
    var allRelationship = querySnapshot.docs.map((e) => e.data()).toList();
    var userRelationships = allRelationship
        .where((element) =>
            (element['userID1'] == userId || element['userID2'] == userId))
        .toList();
    return userRelationships;
  }

  //TODO: Get conversation
  Future<List<Map<String, dynamic>>> getConversation(userId) async {
    throw UnimplementedError();
  }

  // Stream<List<MapEntry<dynamic, dynamic>>> getOnlineUserStream() {
  //   return FirebaseDatabase.instance
  //       .ref()
  //       .child('user_status')
  //       .onValue
  //       .map((event) {
  //     var dataSnapshot = event.snapshot;
  //     print(
  //         'DATASNAPSHOT: $dataSnapshot;\n DATASNAPSHOT VALUE: ${dataSnapshot.value};\n DATASNAPSHOT KEY: ${dataSnapshot.key}');
  //     var allUserStatuses = dataSnapshot.value as Map<dynamic, dynamic>;
  //     var allOnlineUser = allUserStatuses.entries
  //         .where((entry) => entry.value['state'] == 'online')
  //         .toList();
  //     var onlineFriends =
  //         allOnlineUser.where((element) => element.key != userId).toList();
  //     print('ONLINE FRIENDS: $onlineFriends');
  //     return onlineFriends;
  //   });
  // }

  Future<List<MapEntry<dynamic, dynamic>>> getOnlineUsers() async {
    var dataSnapshot =
        await FirebaseDatabase.instance.ref().child('user_status').get();
    var allUserStatuses = dataSnapshot.value as Map<dynamic, dynamic>;
    var allOnlineUser = allUserStatuses.entries
        .where(
            (entry) => entry.value['state'] == 'online' && entry.key != userId)
        .toList();
    return allOnlineUser;
  }

  Stream<List<Map<String, dynamic>>> getFriendsData() {
    return getOnlineUsers().asStream().asyncMap((allOnlineUser) async {
      //Take all online user and get their data
      List<Map<String, dynamic>> friendData = [];
      var userRelationships = await getRelationship();
      await Future.forEach(allOnlineUser, (element) async {
        var value = await FirebaseFirestore.instance
            .collection('users')
            .doc(element.key)
            .get();
        //Check if the online user is friend with the current user
        var isFriend = userRelationships.any((relationship) =>
            (relationship['userID1'] == value.id ||
                relationship['userID2'] == value.id));
        if (isFriend && value.data() != null) {
          friendData.add(value.data()!);
        }
      });
      print("FRIEND DATA: $friendData");
      return friendData;
    });
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
                await UserStatusServices().setUserStatus('offline');
                await FirebaseAuth.instance.signOut();
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: (){},
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
              child: StreamBuilder(
                //TODO: get user infor stream
                stream: getFriendsData(),
                builder: ((ctx, sns) {
                  if (sns.hasError) {
                    return const Center(
                      child: Text('Error loading online users'),
                    );
                  }
                  if (sns.hasData && sns.data != null) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: sns.data!.length,
                      //itemCount: 10,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 70,
                              width: 70, // Adjust width as needed
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                            Text(
                              sns.data![index]['fName'],
                              //'Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return Container();
                }),
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
