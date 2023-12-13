// moving away from the local database
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfirsttutorial/services/cloud_crud/cloud_note.dart';
import 'package:myfirsttutorial/services/cloud_crud/cloud_storage_constants.dart';
import 'package:myfirsttutorial/services/cloud_crud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // Making [FirebaseCloudStorage] a singleton
  // First, create a private constructor
  // We could name this anything but since it is a singleton and there is only
  // going to be one instance and that instance is going to be shared, the
  // _sharedInstance name fits.
  FirebaseCloudStorage._sharedInstance();
  // Secondly, create a private instance
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  // Then, we create a factory constructor, which is the default constructor
  // [FirebaseCloudStorage], using that private shared instance [_shared].
  factory FirebaseCloudStorage() => _shared;

  // Grabbing all the notes, a [CollectionReference] is like a stream for both,
  // reading and writing
  final notes = FirebaseFirestore.instance.collection(notesCollectionName);

  // A [Stream] is a sequence of asynchronous events.
  // It represents a flow of data that you can listen to over time.
  // We need a [Stream] to keep our application up-to-date with changes in the
  // cloud.
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    // .snapshots returns a [Stream] of [QuerySnapshot]s, not just one.
    // Each snapshot is an (event) which has a list of all of the documents
    // (docs) inside the database.
    return notes.snapshots().map((event) => event.docs
        // Then from this list of documents, only the documents which belongs
        // to the current user is used (to create instances of [CloudNote]).
        .map((doc) => CloudNote.fromSnapshot(doc))
        // This .where is clause is from dart:core which returns an object based
        // on a test, in this case user IDs being equal.
        .where((note) => note.ownerUserId == ownerUserId));
  }

  // CRUD
  // C: A function to create new notes
  Future<CloudNote> creatNewNote({required String ownerUserId}) async {
    // Firestore is a NoSQL database, it is document based. There is no real
    // like in SQLite. You provide key-value pairs [Map]s. Everything that is
    // added to the Collection/Database is going to be packaged into a document,
    // with the fields (keys) and the values (values) that we have provided.
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: "",
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: "",
    );
  }

  // R: A function to get notes by user ID
  // Every note [CloudNote] has an ownerId and a text field
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    // We are going to do a search inside or notes [CollectionReference] using
    // the .where clause. This clause can throw an exception
    try {
      return await notes
          // We want to search for all [CloudNote]s which belongs to ownerUserId
          // .where clause returns a [Query]
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          // From the [Query], get a
          // [QuerySnapshot<Map<String, dynamic>>]
          // .get is async. "Fetch the documents for this query"
          .get()
          // After the .get returns the snapshot, .then will be executed which
          // is used when a [Future] completes. It returns a value of that
          // [Future] which can be used to a synchronous value or another
          // future. (value) is the documents from the query
          .then(
              (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  // U: A function to update notes
  Future<void> updateNote({
    required documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  // D: A function to delete notes
  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
