import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realtime_chatapp/models/user_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_services.g.dart';

class UserServices {
  Future<UserModel> getCurrentUserInformation() async {
    // Get user data from firebase
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    //print(documentSnapshot.data());
    var data = documentSnapshot.data();
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
      var currentUserInformation =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      //print(currentUserInformation.dateOfBirth);
      return currentUserInformation;
    }
  }

  Future<List<UserModel>> getUsersInformation() async {
    // Get all users data from firebase
    var querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    var usersInformation =
        querySnapshot.docs.map((e) => UserModel.fromMap(e.data())).toList();
    return usersInformation;
  }
}

@riverpod
UserServices userServices(ref) {
  return UserServices();
}
