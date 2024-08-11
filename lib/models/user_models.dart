import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fName;
  final String lName;
  final String phone;
  final String email;
  final String photoUrl;
  final bool isProfileComplete;
  final DateTime dateOfBirth;

  UserModel({
    required this.uid,
    required this.fName,
    required this.lName,
    required this.phone,
    required this.email,
    required this.photoUrl,
    required this.isProfileComplete,
    required this.dateOfBirth,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      fName: data['fName'] ?? '',
      lName: data['lName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phoneNumber'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      isProfileComplete: data['isProfileComplete'] ?? false,
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
    );
  }
}
