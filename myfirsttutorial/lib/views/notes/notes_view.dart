// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myfirsttutorial/constants/routes.dart';
import 'package:myfirsttutorial/enums/menu_action.dart';
import 'package:myfirsttutorial/services/auth/auth_service.dart';
import 'package:myfirsttutorial/services/crud/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;

  // The (!) tells flutter to forcefully unwrap it. As we are sure that the (.currentUser) can not be null, we use (!) to tell flutter that.
  String get userEmail => AuthService.firebase().currentUser!.email!;

  // opening and closing the DataBase
  @override
  void initState() {
    _notesService = NotesService();
    // No need for the following as we have a method to ensure the DB is open (_ensureDbIsOpen())
    // _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Main UI - Notes View"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      await AuthService.firebase().logOut();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                    break;
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, // value is what you see/get
                    child: Text("Log Out"), // child is what the user sees
                  ),
                ];
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            // this is the FutureBuilder's connection state
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                // the widget returned by this FutureBuilder is a StreamBuilder
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    // this is the Stream Builder's connection state
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      // Since there is nothing in the stream, the state is .waiting
                      // as soon as there is an element the state changes to .active
                      case ConnectionState.active:
                        // two consecutive cases = Implicit Fall through; when a case doesn't have any logic
                        return const Text("Waiting for all notes...");

                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                );

              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Log out"),
          )
        ],
      );
    },
  ).then((value) => value ?? false);
}
