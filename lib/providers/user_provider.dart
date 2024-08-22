import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chatapp/models/user_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

class UserServices {
  Future<UserModel> getUserInformation(String uid) async {
    // Get user data from firebase
    var documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    //print(documentSnapshot.data());
    var data = documentSnapshot.data();
    // print('USER (getUserInformation - user_provider): $uid');
    // print('DATA FETCH FROM USER (getUserInformation - user_provider): $data');
    if (data == null) {
      return UserModel(
        uid: '1',
        fName: 'Error',
        lName: 'Error',
        phone: 'Error',
        email: 'Error',
        photoUrl: '',
        isProfileComplete: false,
        dateOfBirth: DateTime.now(),
      );
    } else {
      var userInformation =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      //print('USER INFOR: $userInformation');
      return userInformation;
    }
  }

  Future<List<UserModel>> getUsersInformation(List<dynamic> ids) async {
    // Get all users data from firebase
    List<UserModel> usersInformation = [];
    await Future.forEach(ids, (id) async {
      try {
        // print('USER ID (getUsersInformation - user_provider): $id');
        var docSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(id).get();
        // print(
        //     'USER DATA (getUsersInformation - user_provider): ${docSnapshot.data()}');
        usersInformation
            .add(UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>));
      } catch (e) {
        print(
            'ERROR FETCHING USERS DATA (getUsersInformation - user_provider.dart): $e');
      }
    });
    return usersInformation;
  }

  String formateLastActiveTime(DateTime time, String status) {
    var now = DateTime.now();
    var difference = now.difference(time);
    if (status == 'online') {
      return 'online';
    } else {
      if (difference.inDays > 0) {
        return DateFormat('dd/MM/yyyy').format(time);
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'few seconds ago';
      }
    }
  }

  Future<String> getUserActiveTime(String uid) async {
    var userStatusRef =
        FirebaseDatabase.instance.ref().child('user_status').child(uid);
    //Once() looks up in cache first, if there's no date it will make a network request - get() always makes network request
    var snapshotLastchange = await userStatusRef.child('last_changed').get();
    var snapshotUserstatus = await userStatusRef.child('state').get();
    if (snapshotLastchange.exists && snapshotUserstatus.exists) {
      int timestamp = snapshotLastchange.value as int;
      String status = snapshotUserstatus.value as String;
      var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return formateLastActiveTime(dateTime, status);
    }
    return 'error';
  }
}

@riverpod
UserServices userDetail(ref) {
  return UserServices();
}
