// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myfirsttutorial/constants/routes.dart';
import 'package:myfirsttutorial/enums/menu_action.dart';
import 'package:myfirsttutorial/services/auth/auth_service.dart';
import 'package:myfirsttutorial/services/cloud_crud/cloud_note.dart';
import 'package:myfirsttutorial/services/cloud_crud/firebase_cloud_storage.dart';
import 'package:myfirsttutorial/utilities/dialogs/logout_dialog.dart';
import 'package:myfirsttutorial/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  // opening and closing the DataBase
  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
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
      // we got rid of the future builder because we dont need to manage users,
      // firebase will do that for us
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          // this is the Stream Builder's connection state
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            // Since there is nothing in the stream, the state is .waiting
            // as soon as there is an element the state changes to .active
            case ConnectionState.active:
              // two consecutive cases = Implicit Fall through; when a case doesn't have any logic
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                // print(allNotes);
                // return const Text("Got All the notes");
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                  },
                  onTap: (CloudNote note) {
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
      ),
    );
  }
}
