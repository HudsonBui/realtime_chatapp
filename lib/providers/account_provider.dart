import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realtime_chatapp/models/user_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_provider.g.dart';

@riverpod
class AccountInformationNotifier extends _$AccountInformationNotifier {
  //value initialization
  @override
  Future<UserModel> build() async {
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

  //function for modifing the value
  Future updateUser(UserModel userUpdated) async {
    Timestamp timestamp = Timestamp.fromDate(userUpdated.dateOfBirth);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userUpdated.uid)
        .update({
      'uid': userUpdated.uid,
      'fName': userUpdated.fName,
      'lName': userUpdated.lName,
      'phoneNumber': userUpdated.phone,
      'dateOfBirth': timestamp,
      'photoUrl': userUpdated.photoUrl,
    });

    state = AsyncValue.data(userUpdated);
  }
}
