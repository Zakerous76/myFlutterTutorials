import 'package:flutter/material.dart';
import 'package:myfirsttutorial/utilities/dialogs/generic_dialog.dart';

Future<void> showCannoShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Sharing",
    content: "You cannot share an empty note!",
    // option builder return a [Map] with only one key-value pair
    optionsBuilder: () => {
      "OK": null,
    },
  );
}
