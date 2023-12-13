// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myfirsttutorial/constants/routes.dart';
import 'package:myfirsttutorial/enums/menu_action.dart';
import 'package:myfirsttutorial/services/auth/auth_service.dart';
import 'package:myfirsttutorial/services/local_crud/notes_service.dart';
import 'package:myfirsttutorial/utilities/dialogs/logout_dialog.dart';
import 'package:myfirsttutorial/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;

  // The (!) tells flutter to forcefully unwrap it. As we are sure that the (.currentUser) can not be null, we use (!) to tell flutter that.
  String get userEmail => AuthService.firebase().currentUser!.email;

  // opening and closing the DataBase
  @override
  void initState() {
    _notesService = NotesService();
    // No need for the following as we have a method to ensure the DB is open (_ensureDbIsOpen())
    // _notesService.open();
    super.initState();
  }

  // We don't want to close DB everytime we hot reload.
  // @override
  // void dispose() {
  //   _notesService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Main UI - Notes View"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
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
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
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
                        if (snapshot.hasData) {
                          final allNotes =
                              snapshot.data as List<LocalDatabaseNote>;
                          // print(allNotes);
                          // return const Text("Got All the notes");
                          return NotesListView(
                            notes: allNotes,
                            onDeleteNote: (note) async {
                              await _notesService.deleteNote(id: note.id);
                            },
                            onTap: (LocalDatabaseNote note) {
                              Navigator.of(context).pushNamed(
                                createOrUpdateNoteRoute,
                                arguments: note,
                              );
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }

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
