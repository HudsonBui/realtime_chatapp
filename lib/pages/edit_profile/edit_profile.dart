import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chatapp/models/user_models.dart';
import 'package:realtime_chatapp/providers/account_provider.dart';
import 'package:realtime_chatapp/utils/text_style.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({required this.user, super.key});
  final UserModel user;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  DateTime? dateOfBirthController;
  var dateOfBirthFormatted;

  void pickDateTime() {
    var initialDate = DateTime.now();
    var firstDate = DateTime(DateTime.now().year - 100);
    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now(),
    ).then((value) {
      if (value != null) {
        setState(() {
          dateOfBirthController = value;
          dateOfBirthFormatted = DateFormat('dd/MM/yyyy').format(value);
        });
      }
    });
  }

  Future<bool> checkPhoneNumber() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumberController.text.trim())
        .get();
    var userData = querySnapshot.docs.map((e) => e.data()).toList();

    // if (phoneNumberController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).clearSnackBars();
    //   var snackBar = const SnackBar(
    //     content: Text('Please enter your phone number!'),
    //     duration: Duration(seconds: 2),
    //   );
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   return false;
    // }
    if (phoneNumberController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('Your phone number must be 10 charaters!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    if (int.tryParse(phoneNumberController.text) == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('Your phone number must not contain Alphabet charater!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    if (userData[0]['phoneNumber'] == phoneNumberController.text.trim()) {
      return true;
    }
    if (userData.isNotEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('This phone number is already in use!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    return true;
  }

  // Future<bool> checkData() async {
  //   if (firstNameController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).clearSnackBars();
  //     var snackBar = const SnackBar(
  //       content: Text('Please enter your first name!'),
  //       duration: Duration(seconds: 2),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     return false;
  //   }
  //   if (lastNameController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).clearSnackBars();
  //     var snackBar = const SnackBar(
  //       content: Text('Please enter your last name!'),
  //       duration: Duration(seconds: 2),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     return false;
  //   }
  //   if (dateOfBirthController == null) {
  //     ScaffoldMessenger.of(context).clearSnackBars();
  //     var snackBar = const SnackBar(
  //       content: Text('Please pick your date of birth!'),
  //       duration: Duration(seconds: 2),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //     return false;
  //   }
  //   var isPhoneNumberValid = await checkPhoneNumber();
  //   if (!isPhoneNumberValid) return false;
  //   return true;
  // }

  void setDefaultValue() {
    if (firstNameController.text.trim().isEmpty) {
      firstNameController.text = widget.user.fName;
    }
    if (lastNameController.text.trim().isEmpty) {
      lastNameController.text = widget.user.lName;
    }
    if (dateOfBirthController == null) {
      dateOfBirthController = widget.user.dateOfBirth;
      dateOfBirthFormatted =
          DateFormat('dd/MM/yyyy').format(widget.user.dateOfBirth);
    }
    if (phoneNumberController.text.trim().isEmpty) {
      phoneNumberController.text = widget.user.phone;
    }
  }

  void setData() async {
    print('SETDATA CALLED');
    setDefaultValue();
    var isDataValid = await checkPhoneNumber();
    if (!isDataValid) {
      print('Data is not valid!');
      return;
    }

    Timestamp dateOfBirth = Timestamp.fromDate(dateOfBirthController!);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'fName': firstNameController.text,
      'lName': lastNameController.text,
      //TODO: Add update user's photo
      'phoneNumber': phoneNumberController.text,
      'dateOfBirth': dateOfBirth,
      'isProfileComplete': true,
    });

    await ref
        .read(accountInformationNotifierProvider.notifier)
        .updateUser(UserModel(
          uid: FirebaseAuth.instance.currentUser!.uid,
          fName: firstNameController.text,
          lName: lastNameController.text,
          phone: phoneNumberController.text,
          email: widget.user.email,
          photoUrl: '',
          isProfileComplete: true,
          dateOfBirth: dateOfBirthController!,
        ));
    ScaffoldMessenger.of(context).clearSnackBars();
    var snackBar = const SnackBar(
      content: Text('Profile updated successfully!'),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Timestamp dateOfBirthDefaultTS = widget.user.dateOfBirth;
    // DateTime dateOfBirthDefaultDT = dateOfBirthDefaultTS.toDate();
    DateTime dateOfBirthDefaultDT = widget.user.dateOfBirth;
    var dateOfBirthDefaultFormatted =
        DateFormat('dd/MM/yyyy').format(dateOfBirthDefaultDT);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 100, bottom: 30),
              child: Icon(Icons.person, size: 100),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    hintText: widget.user.fName,
                    prefixIcon: const Icon(Icons.supervised_user_circle),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: widget.user.lName,
                    prefixIcon:
                        const Icon(Icons.supervised_user_circle_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(
                    hintText: widget.user.phone,
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: GestureDetector(
                onTap: pickDateTime,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black54, width: 1),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            dateOfBirthController == null
                                ? dateOfBirthDefaultFormatted.toString()
                                : dateOfBirthFormatted.toString(),
                            style: smallTextStyle),
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                            size: 30,
                          ),
                          onPressed: pickDateTime,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: setData,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
