import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
              print("Button Pressed");
              final email = _email.text;
              final password = _password.text;
              try {
                final userCredential = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                        email: email, password: password);
                print("User logged in: ${userCredential.user?.email}");
              } catch (e) {
                if (e is FirebaseAuthException) {
                  if (e.code == "weak-password")
                    print("Weak Password");
                  else if (e.code == "email-already-in-use")
                    print("Email already in use my nigga!");
                  else if (e.code == "invalid-email")
                    print("Invalid Email my nigga!");
                  else {
                    print('Firebase Authentication Error: ${e.code}');
                    print(
                        'Firebase Authentication Error Message: ${e.message}');
                  }
                } else {
                  print('Error: $e');
                }
              }
            },
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("/login/", (route) => false);
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
