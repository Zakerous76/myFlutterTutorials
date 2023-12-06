import 'package:flutter/material.dart';
import 'package:myfirsttutorial/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
    context: context,
    title: "AN error occured",
    content: text,
    optionsBuilder: () => {
      // an inline function that returns a map/dict
      "OK": null,
    },
  );
}
