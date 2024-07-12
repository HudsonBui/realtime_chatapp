import 'package:flutter/material.dart';
import 'package:realtime_chatapp/pages/auth/sign_in.dart';
import 'package:realtime_chatapp/pages/auth/sign_up.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showSignIn = true;

  void toggleWidget() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return SignInPage(showSignUp: toggleWidget);
    } else {
      return SignUpPage(showSignIn: toggleWidget);
    }
  }
}
