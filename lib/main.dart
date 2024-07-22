import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:realtime_chatapp/pages/auth/fill_infor.dart';
import 'package:realtime_chatapp/screen/auth_screen.dart';
import 'package:realtime_chatapp/screen/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XiaoMi Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<DocumentSnapshot?>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .snapshots(),
              builder: (ctx, sns) {
                if (sns.hasData && sns.data!.data() != null) {
                  var userData = sns.data!.data() as Map<String, dynamic>;
                  if (userData['isProfileComplete']) {
                    return const Dashboard();
                  } else {
                    return FillInforPage(userId: snapshot.data!.uid);
                  }
                }
                return const AuthScreen();
              },
            );
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
