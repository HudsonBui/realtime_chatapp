import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realtime_chatapp/pages/dashboard/db_content.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var userId = FirebaseAuth.instance.currentUser!.uid;

  Future<String> getUserName(userId) async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var userData = userDoc.data() as Map<String, dynamic>;
    String userName = userData['fName'];
    return userName;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserName(userId),
      builder: (ctx, sns) {
        if (sns.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (sns.hasData) {
          var userName = sns.data as String;
          return DashboardContent(userName: userName);
        }
        return const Center(
          child: Text(
            'Error Occurred!',
            style: TextStyle(decoration: TextDecoration.none),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
