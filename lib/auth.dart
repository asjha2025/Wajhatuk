import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> registerUser({
  required String name,
  required String email,
  required String password,
  required String role,
}) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // After registration, save user data to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .set({
      'name': name,
      'email': email,
      'role': role,
    });
  } on FirebaseAuthException catch (e) {
    print('Error: ${e.message}');
  }
}

Future<void> loginUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    print('Error: ${e.message}');
  }
}
