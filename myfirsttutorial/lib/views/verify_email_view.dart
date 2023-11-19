// ignore: unused_import
// ignore_for_file: use_build_context_synchronously

// import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:myfirsttutorial/constants/routes.dart';
import 'package:myfirsttutorial/services/auth/auth_service.dart';

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
          const Text(
            "We've sent you an email verification. Please open it to verify your account.",
          ),
          const Text(
            "If you haven't received a verification email yet, press the button below.",
          ),
          // This option is disabled because we only want verified users to be able to use the app.
          // Since our database stores notes and users based on email, without verification, someone can use someone elses email and access that user's information.
          // TextButton(
          //   onPressed: () {
          //     Navigator.of(context).pushNamedAndRemoveUntil(
          //       notesRoute,
          //       (route) => false,
          //     );
          //   },
          //   child: const Text("I will verify later"),
          // ),
          TextButton(
            onPressed: () async {
              final user = AuthService.firebase().currentUser;
              if (user?.isEmailVerified == false) {
                AuthService.firebase()
                    .sendEmailVerification(); // We have decided to this in the register_view automatically as well.
                Navigator.of(context).pushNamedAndRemoveUntil(
                  notesRoute,
                  (_) => false,
                );
              }
            },
            child: const Text("Send email verification again"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (_) => false,
              );
            },
            child: const Text("I have verified the email (Restart)"),
          ),
        ],
      ),
    );
  }
}
