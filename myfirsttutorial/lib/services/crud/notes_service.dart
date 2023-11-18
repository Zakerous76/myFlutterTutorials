import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:myfirsttutorial/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart'; // sqlite is being managed by sqflite
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  // A getter for the database. If the database is open, it will return it. If not, then it will throw an exception.
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  // opening a database is asynchronous
  Future<void> open() async {
    // this function opens the database and stores it in a _db
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(
          dbPath); // openDatabase can create the database if it is not created
      _db = db;
      // create user table if not exists
      await db.execute(createUserTable);
      // create note table if not exists
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    } catch (e) {
      rethrow;
    }
  }

  // closes the database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    // first check a user already exists with the same email
    // In case if there was constraint on emails being unique, this would
    // prevent getting an error from sqlite
    // .query returns a list of rows.
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserNotExistsException();
    }

    // it returns the userId
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    // from the userTable all rows corresponding to the email will be deleted.
    // if deletedCount == 1, then the user is deleted. If deletedCount == 0, then the user was not in the userTable
    final deletedCount = await db.delete(
      userTable,
      where: "email: = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  // Returns a note with its owner
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // first make sure that the owner user exists in the database
    final dbUser = await getUser(email: owner.email);
    // make sure that the owner is the real owner
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const text = '';
    // create the note
    final notesId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: notesId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    return note;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  // returns a specific note
  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
    );

    final result = notes.map((notesRow) => DatabaseNote.fromRow(notesRow));

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    }

    return result;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    // make sure the note already exists in the database
    await getNote(id: note.id);

    final updatedRowsCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatedRowsCount == 0) {
      throw CouldNoteUpdateNoteException();
    } else {
      return await getNote(id: note.id);
    }
  }
}

// dart representations of the database
@immutable // because it is const
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });
  // a row inside the user table
  // database will fetch the values and create its represntation of the data using the data read from here
  // Map<String, Object?>
  DatabaseUser.fromRow(
      Map<String, Object?> map) // this is a constructor short-hand
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => "Person, ID = $id, email: $email";

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;
  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  // a row inside the user table
  // database will fetch the values and create its represntation of the data using the data read from here
  // Map<String, Object?>
  DatabaseNote.fromRow(
      Map<String, Object?> map) // this is a constructor short-hand
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "Note, ID = $id, user_Id: $userId, isSyncedWithCloud: $isSyncedWithCloud, text: $text";

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const noteTable = "note";
const userTable = "user";
const idColumn = "id";
const userIdColumn = "user_id";
const emailColumn = "email";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_column";
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

const createNoteTable = '''CREATE TABLE IF NOT EXOSTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';