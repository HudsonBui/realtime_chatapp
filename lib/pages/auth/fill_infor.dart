import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chatapp/screen/dashboard_screen.dart';
import 'package:realtime_chatapp/style/text_style.dart';

class FillInforPage extends StatefulWidget {
  const FillInforPage({required this.userId, super.key});
  final userId;

  @override
  State<FillInforPage> createState() => _FillInforPageState();
}

class _FillInforPageState extends State<FillInforPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  var _dateOfBirthController;
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
          _dateOfBirthController = value;
          dateOfBirthFormatted = DateFormat('dd/MM/yyyy').format(value);
        });
      }
    });
  }

  void setData() async {
    if (_dateOfBirthController == null) {
      var snackBar = const SnackBar(
        content: Text('Please pick your date of birth!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    Timestamp dateOfBirth = Timestamp.fromDate(_dateOfBirthController);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .set({
      'fName': _firstNameController.text,
      'lName': _lastNameController.text,
      'dateOfBirth': dateOfBirth,
      'isProfileComplete': true,
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
