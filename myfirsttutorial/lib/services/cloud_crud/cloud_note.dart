import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfirsttutorial/services/cloud_crud/cloud_storage_constants.dart';

// An immutable class is a class whose instances cannot be modified after they
// are created.
@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  // The [Map] object that we recieve from Firestore is wrapped with a
  // [QueryDocumentSnapshot].
  // After recieving the snapshot, it needs to be unwrapped and the use the
  // [Map] to create instance of [CloudNote]
  //
  // The (:) symbol is used to initialize the instance with the data recieved
  // from the snapshot
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
