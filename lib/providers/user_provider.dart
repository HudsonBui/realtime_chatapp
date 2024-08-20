import 'package:cloud_firestore/cloud_firestore.dart';
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
    print('USER: $uid');
    print('DATA FETCH FROM USER: $data');
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
      print('USER INFOR: $userInformation');
      return userInformation;
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
UserServices userDetail(ref) {
  return UserServices();
}
