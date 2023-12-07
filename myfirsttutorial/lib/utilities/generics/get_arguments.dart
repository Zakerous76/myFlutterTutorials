import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);

    // if we can grab arguments from modalRoute,
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments;

      // and if those arguments are not null,
      if (args != null && args is T) {
        // return those arguments as the datatype that it was recieved as.
        return args as T;
      }
    }

    // else: return null
    return null;
  }
}
