import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chatapp/navbar/nav_bar.dart';
import 'package:realtime_chatapp/pages/search/search_friend.dart';
import 'package:realtime_chatapp/providers/user_provider.dart';
import 'package:realtime_chatapp/screen/chat_screen.dart';
import 'package:realtime_chatapp/services/user_status_services.dart';
import 'package:realtime_chatapp/providers/chats_provider.dart';

class DashboardContent extends ConsumerStatefulWidget {
  const DashboardContent({super.key});

  @override
  ConsumerState<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<DashboardContent> {
  var currentUser = FirebaseAuth.instance.currentUser;

  Future<List<String>> getFriendsId() async {
    List<String> friendIds = [];
    var querySnapshot =
        await FirebaseFirestore.instance.collection('friends').get();
    var allRelationship = querySnapshot.docs.map((e) => e.data()).toList();
    var userRelationships = allRelationship
        .where((element) => (element['userID1'] == currentUser!.uid ||
            element['userID2'] == currentUser!.uid))
        .toList();

    for (var element in userRelationships) {
      if (element['userID1'] == currentUser!.uid) {
        friendIds.add(element['userID2']);
      } else {
        friendIds.add(element['userID1']);
      }
    }
    return friendIds;
  }

  Stream<List<Map<String, dynamic>>> getOnlineFriendsData() {
    return FirebaseDatabase.instance
        .ref()
        .child('user_status')
        .onValue
        .asyncMap((event) async {
      var allOnlineUserStatuses = event.snapshot.value as Map<dynamic, dynamic>;
      var allOnlineUser = allOnlineUserStatuses.entries
          .where((entry) =>
              entry.value['state'] == 'online' && entry.key != currentUser!.uid)
          .toList();

      List<Map<String, dynamic>> friendData = [];

      var friendIds = await getFriendsId();
      await Future.forEach(allOnlineUser, (element) async {
        var value = await FirebaseFirestore.instance
            .collection('users')
            .doc(element.key)
            .get();
        var isFriend = friendIds.any((id) => id == value.id);
        if (isFriend && value.data() != null) {
          friendData.add(value.data()!);
        }
      });

      return friendData;
    });
  }

  Future<List<Map<String, dynamic>>> getAllFriendsData() async {
    final List<String> friendIds = await getFriendsId();
    //print('FRIEND IDS: $friendIds');

    final List<Map<String, dynamic>> friendData = [];
    await Future.forEach(friendIds, (element) async {
      final Map<String, dynamic> userData = await getUserData(element);
      //print('USER SNAPSHOT: ${userSnapshot.data()}');
      if (userData.isNotEmpty) {
        friendData.add(userData);
      } else {
        print('User data is empty');
      }
    });

    return friendData;
  }

  Future<List<Map<String, dynamic>>> getSuggestionFriendsData() async {
    //TODO: Get suggestion friends data
    throw UnimplementedError();
  }

  Future<Map<String, dynamic>> getUserData(uid) async {
    DocumentSnapshot<Map<String, dynamic>> userFetchedData;
    try {
      userFetchedData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userFetchedData.data()!;
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  String formateLastMessTime(DateTime time) {
    var now = DateTime.now();
    var difference = now.difference(time);
    if (difference.inDays < 365) {
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes} minutes ago';
        }
        return DateFormat('h:mm a').format(time);
      }
      return DateFormat('h:mm a dd/MM').format(time);
    }
    return DateFormat('h:mm a dd/MM/yyyy').format(time);
  }

  @override
  Widget build(BuildContext context) {
    var chatNotifer = ref.watch(chatNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      drawer: const MainNavBar(),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
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
            onTap: () async {
              //var friends = await getRelationship();
              var friends = await getAllFriendsData();
              // var friends = await getFriendsId();
              print('FRIENDS: $friends');
              showSearch(
                context: context,
                delegate: SearchFriend(
                  allFriendsData: await getAllFriendsData(),
                ),
              );
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
                  const SizedBox(width: 10),
                  Text(
                    'Search',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder(
            //TODO: get user infor stream
            stream: getOnlineFriendsData(),
            builder: ((ctx, sns) {
              if (sns.hasError) {
                return const Center(
                  child: Text('Error loading online users'),
                );
              }
              if (sns.hasData && sns.data != null && sns.data!.isNotEmpty) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: SizedBox(
                    height: 110,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListView.builder(
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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Item $index',
                                      style:
                                          const TextStyle(color: Colors.white),
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
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Container();
            }),
          ),
          chatNotifer.when(
            data: (chat) {
              return chat.isEmpty
                  ? const Center(
                      child: Text(
                        'Start a conversation',
                        style: TextStyle(fontSize: 20, color: Colors.black45),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: chat.length,
                        itemBuilder: (context, index) {
                          //get id of the friend of the current user
                          var friendUID = chat[index]
                              .participants
                              .where((element) => element != currentUser!.uid)
                              .first;
                          var friendInforServices = ref
                              .watch(userDetailProvider)
                              .getUserInformation(friendUID);
                          return FutureBuilder(
                            future: friendInforServices,
                            builder: (ctx, snp) {
                              print('USER MODEL: ${snp.data}');
                              if (snp.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...');
                              }
                              if (snp.hasError) {
                                return Text(snp.error.toString());
                              }
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) =>
                                              ChatScreen(user: snp.data!)));
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
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
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${snp.data!.fName} ${snp.data!.lName}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(chat[index]
                                                        .lastMessage),
                                                    Text(formateLastMessTime(
                                                        chat[index]
                                                            .lastMessageTime)),
                                                  ],
                                                ),
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
                          );
                        },
                      ),
                    );
            },
            error: (error, stack) {
              return Center(
                child: Text(error.toString()),
              );
            },
            loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }
}
