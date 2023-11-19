import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  // since notes from the database are retrieved using emails, we need AuthUser to have an email because UI accesses a Firebase using AuthService and consequently, AuthUser
  // String is optional (String?) because the email getter for User in its definition is also optional String.
  // But in our application, there always IS an email because in order to use the application, one must have an email.
  final String? email;
  final bool isEmailVerified;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        // The AuthUser's email is read from the Firebase User
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}
