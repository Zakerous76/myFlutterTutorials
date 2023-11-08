// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:myfirsttutorial/constants/routes.dart';
import 'package:myfirsttutorial/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

// Each widget has a state and the state and to create it:
class _RegisterViewState extends State<RegisterView> {
  // These controllers are here to set a proxy of communication, to facilitate data retrievel between the TextField and the app itself. SO that input data can be used.
  late final TextEditingController _email;
  // "late" promises that the variable will be assigned a value "later"
  late final TextEditingController _password;

  // Stateful widgets have initState and dispose functions that intilizes and cleans the widgets.
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  void dispse() {
    _email.dispose();
    _password.dispose();
    super.initState();
  }

  // Building the widget
  @override
  Widget build(BuildContext context) {
    // To make sure that the core flutter engine is in place.
    WidgetsFlutterBinding.ensureInitialized();
    // We are not going to return a scaffold widget but rather a column widget which is going to replace the "body" of the HomePage's scaffold.
    //  Well, technically, this page will return a column widget to the future builder of the HomePage scaffold.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter your email here",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: "Enter your password here",
            ),
          ),
          TextButton(
            onPressed: () async {
              devtools.log("Button Pressed");
              final email = _email.text;
              final password = _password.text;
              try {
                // final userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                // devtools.log("User Created: ${userCredential.user?.email}");

                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                Navigator.of(context).pushNamed(
                  verifyEmailRoute,
                  // (route) => false means to remove everything and not to keep anything
                );
              } catch (e) {
                if (e is FirebaseAuthException) {
                  if (e.code == "weak-password") {
                    await showErrorDialog(
                      context,
                      "Weak Password my nigga!\nWeak just like yo mama!\nAt least 6 characters, my nigga.",
                    );
                  } else if (e.code == "email-already-in-use") {
                    showErrorDialog(
                      context,
                      "Why you trynna steal someone else's email.\nThis aint the hood.\nEnter an email that belongs to you, my nigga!",
                    );
                  } else if (e.code == "invalid-email") {
                    showErrorDialog(
                      context,
                      "My niggaaaa! You stupid!\nAn email must have @something.com.",
                    );
                  } else {
                    showErrorDialog(
                      context,
                      'Firebase Authentication Error: ${e.code}\nFirebase Authentication Error Message: ${e.message}',
                    );
                  }
                } else {
                  showErrorDialog(
                    context,
                    'Error: $e',
                  );
                }
              }
            },
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text("Already registered? Login here!"),
          )
        ],
      ),
    );
    // Scaffold of the entire widget area, where the user can interact and etc.
    // return Scaffold(
    //   appBar: AppBar(title: const Text("Register")),

    //   // The body of the scaffold is wrapped inside a FutureBuilder widget because we want to build the widget based on the information we get from the future
    //   // Creates a widget that builds itself based on the latest snapshot of interaction with a [Future].
    //   body: FutureBuilder(
    //     // The future that it awaits is this:
    //     future: Firebase.initializeApp(
    //       options: DefaultFirebaseOptions.currentPlatform,
    //     ),
    //     // Then, it will build this, using the snapshot of the  future above:
    //     builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //       switch (snapshot.connectionState) {
    //         case ConnectionState.done:
    //           return (******************)
    //         default:
    //           return const Text("Loading...");
    //       }
    //     },
    //   ),
    // );
  }
}
