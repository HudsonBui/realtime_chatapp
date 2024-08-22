import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime_chatapp/screen/chat_screen.dart';

class SearchFriend extends SearchDelegate<String> {
  SearchFriend({required this.allFriendsData});
  final List<Map<String, dynamic>> allFriendsData;

  var authenticatedUser = FirebaseAuth.instance.currentUser;
  String createParticipantsList(String otherUserId) {
    List<String> participants = [otherUserId];
    participants.add(authenticatedUser!.uid);
    participants.sort();
    print(
        'CHAT ID (createParticipantsList - search_friend): ${participants.join('_')}');
    return participants.join('_');
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, dynamic>> matchQuery = [];
    for (var element in allFriendsData) {
      var userName = element['lName'] + ' ' + element['fName'];
      if (userName.toLowerCase().contains(query.toLowerCase())) {
        print('USER INFOR (buildResults - search_friend): ${element['uid']}');
        matchQuery.add(element);
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Search result',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            const SizedBox(height: 5),
            matchQuery.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'There no match friend',
                        style: TextStyle(color: Colors.black38, fontSize: 15),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: matchQuery.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              print(
                                  'CHAT ID (buildResults - search_friend): ${createParticipantsList(matchQuery[index]['uid'])}');
                              return ChatScreen(
                                chatId: createParticipantsList(
                                    matchQuery[index]['uid']),
                                participantsId: [
                                  matchQuery[index]['uid'],
                                  authenticatedUser!.uid
                                ],
                              );
                            }),
                          );
                        },
                        title: Text(matchQuery[index]['lName'] +
                            ' ' +
                            matchQuery[index]['fName']),
                      );
                    },
                  ),
            const SizedBox(height: 10),
            const Text(
              'People you may know',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            const SizedBox(height: 5),
            //TODO: Add people you may know
          ],
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, dynamic>> matchQuery = [];
    for (var element in allFriendsData) {
      var userName = element['lName'] + ' ' + element['fName'];
      if (userName.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(element);
      }
    }
    return query.isEmpty
        ? const Center(
            child: Text(
              'There is no result!',
              style: TextStyle(color: Colors.black38, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            itemCount: matchQuery.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      print(
                          'CHAT ID (buildSuggestions - search_friend): ${createParticipantsList(matchQuery[index]['uid'])}');
                      return ChatScreen(
                        chatId:
                            createParticipantsList(matchQuery[index]['uid']),
                        participantsId: [
                          matchQuery[index]['uid'],
                          authenticatedUser!.uid
                        ],
                      );
                    }),
                  );
                },
                title: Text(matchQuery[index]['lName'] +
                    ' ' +
                    matchQuery[index]['fName']),
              );
            },
          );
  }
}
