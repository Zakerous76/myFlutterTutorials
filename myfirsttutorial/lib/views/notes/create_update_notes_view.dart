import 'package:flutter/material.dart';
import 'package:myfirsttutorial/services/auth/auth_service.dart';
import 'package:myfirsttutorial/services/local_crud/notes_service.dart';
import 'package:myfirsttutorial/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  LocalDatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  // updating the the text in database as the user updates their text.
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  // to make sure that the _textControllerListener is only added once
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<LocalDatabaseNote> createOrGetExistingNote(
      BuildContext context) async {
    // in here between <>, we told the function the return type.
    final widgetNote = context.getArgument<LocalDatabaseNote>();
    // if we could extract a note, we just have return that note and give the
    // user the ability to modify/update it.
    // it is done by setting the _textcontroller's text as such.
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    } else {
      // we explicitly unwrap the .currentUser . This might crash the app but
      // we can not end up in this view without a user. So crashing would be good.
      final currentuser = AuthService.firebase().currentUser!;
      final email = currentuser.email;
      final owner = await _notesService.getUser(email: email);
      final newNote = await _notesService.createNote(owner: owner);
      _note = newNote;
      return newNote;
    }
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // this must be done while creating the note, not in here. bad
              // idea.
              // _note = snapshot.data;

              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                // multi line text field
                keyboardType: TextInputType.multiline,
                // expanding the text field as the user enters more lines
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Start typing your note...",
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
