import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myfirsttutorial/firebase_options.dart';

void main() {
  runApp(MaterialApp(
    // we are straight up returning the Material from here rather than returning a separate MyApp instance becasue this yields more performance
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Home Page"), backgroundColor: Colors.blue),
      body: FutureBuilder(
          future: Firebase.initializeApp(
              // if its not initialized, the instance of firebase may be null
              options: DefaultFirebaseOptions.currentPlatform),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                // "If the user is non-null, take it. If the user is null then take false"
                if (user?.emailVerified ?? false) {
                  print("You are verified my nigga!");
                } else {
                  print("You are NOT verified my nigga!");
                }
                return const Text("Done");
              default:
                return const Text("Loading...");
            }
          }),
    );
  }
}
