import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_book/service/database_service.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //Login
  Future loginWithUserNameandPassword(String email, String password) async {
    try {
      // User user = (await firebaseAuth.signInWithEmailAndPassword(
      //         email: email, password: password))
      //     .user!;
      return true;
      // if (user != null) {
      //   return true;
      // }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // register
  Future registerUserWithEmailandPassword(
      String fullName, String email, String id) async {
    try {
      // User user = (await firebaseAuth.createUserWithEmailAndPassword(
      //     email: email, password: password))
      //     .user!;
      //
      // if (user != null) {
      //   // call our database service to update the user data.
      //
      // }
      await DatabaseService(uid: id).savingUserData(fullName, email);
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
