import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chatapp/utils/text_style.dart';

class FillInforPage extends StatefulWidget {
  const FillInforPage({required this.userId, super.key});
  final userId;

  @override
  State<FillInforPage> createState() => _FillInforPageState();
}

class _FillInforPageState extends State<FillInforPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  var _dateOfBirthController;
  var dateOfBirthFormatted;
  var user = FirebaseAuth.instance.currentUser;

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
          _dateOfBirthController = value;
          dateOfBirthFormatted = DateFormat('dd/MM/yyyy').format(value);
        });
      }
    });
  }

  Future<bool> checkData() async {
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('Please enter your first name!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    if (_lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('Please enter your last name!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    if (_dateOfBirthController == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('Please pick your date of birth!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    var isPhoneNumberValid = await checkPhoneNumber();
    if (!isPhoneNumberValid) return false;
    return true;
  }

  Future<bool> checkPhoneNumber() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: _phoneNumberController.text.trim())
        .get();
    var userData = querySnapshot.docs.map((e) => e.data()).toList();
    if (userData.isNotEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('This phone number is already in use!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    if (_phoneNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('Please enter your phone number!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    if (_phoneNumberController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('Your phone number must be 10 charaters!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    if (int.tryParse(_phoneNumberController.text) == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      var snackBar = const SnackBar(
        content: Text('Your phone number must not contain Alphabet charater!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
    return true;
  }

  void setData() async {
    print('SETDATA CALLED');
    var isDataValid = await checkData();
    if (!isDataValid) {
      print('Data is not valid!');
      return;
    }

    Timestamp dateOfBirth = Timestamp.fromDate(_dateOfBirthController);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .set({
      //TODO: Add user image field
      'uid': widget.userId,
      'email': user!.email,
      'fName': _firstNameController.text,
      'lName': _lastNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'dateOfBirth': dateOfBirth,
      'isProfileComplete': true,
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Finish things up!', style: greetingText),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: 'Your first name',
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
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: 'Your last name',
                  prefixIcon: const Icon(Icons.supervised_user_circle_outlined),
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
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  hintText: 'Your phone number',
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
                          _dateOfBirthController == null
                              ? 'Pick your date of birth'
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
