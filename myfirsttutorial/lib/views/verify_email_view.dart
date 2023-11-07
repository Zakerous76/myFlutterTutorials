import 'dart:developer' as devtools show log;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfirsttutorial/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
      ),
      body: Column(
        children: [
          const Text("Please verify your email:"),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified == false) {
                user?.sendEmailVerification();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  notesRoute,
                  (_) => false,
                );
              }
            },
            child: const Text("Send email verification"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (_) => false,
            ),
            child: const Text("Go to Login screen"),
          ),
        ],
      ),
    );
  }
}
