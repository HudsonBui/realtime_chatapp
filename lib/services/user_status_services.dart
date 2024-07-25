import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserStatusServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _userStatusDatabaseReference =
      FirebaseDatabase.instance.ref().child('user_status');

  Future<void> setUserStatus(String status) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _userStatusDatabaseReference.child(user.uid).set({
          'state': status,
          'last_changed': ServerValue.timestamp,
        });
      } catch (e) {
        print('Error setting user status: $e');
      }
    }
  }

  Future<void> setupOnlineOfflineListeners() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _userStatusDatabaseReference.child(user.uid).onDisconnect().set(
          {'status': 'offline', 'last_changed': ServerValue.timestamp}).then(
        (_) {
          setUserStatus('online');
        },
      );
    }

    _auth.authStateChanges().listen(
      (User? user) {
        if (user == null) {
          setUserStatus('offline');
        } else {
          setUserStatus('online');
        }
      },
    );

    print('finished setting up online offline listeners');
  }
}
