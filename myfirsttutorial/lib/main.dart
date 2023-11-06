import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myfirsttutorial/firebase_options.dart';
import 'package:myfirsttutorial/views/login_view.dart';
import 'package:myfirsttutorial/views/register_view.dart';
import 'package:myfirsttutorial/views/verify_email_view.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that Flutter is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    // we are straight up returning the Material from here rather than returning a separate MyApp instance becasue this yields more performance
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      "/login/": (context) =>
          const LoginView(), // returns an instance of the loginview
      "/register/": (context) => const RegisterView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            // if its not initialized, the instance of firebase may be null
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (user.emailVerified) {
                  print("Email is verified");
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
              // // "If the user is non-null, take it. If the user is null then take false"
              // if (user?.emailVerified ?? false) {
              //   return const Text("Done");
              // } else {
              //   print("You are NOT verified, you need to verify my nigga!");
              //   // Navigator.of(context).push(MaterialPageRoute(          // Since we are returning a "Column" rather than a scaffold widget from the VerifyEmailView()
              //   //     builder: (context) => const VerifyEmailView()));
              // }
              return const Text("Done");

            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
