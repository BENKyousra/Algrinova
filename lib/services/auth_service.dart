import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  // instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign user in
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    }
    // catch error
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign up regular user
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      print("User successfully registered: ${userCredential.user?.email}");

      // after creating the user, add to users collection
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "email": email,
        "uid": userCredential.user!.uid,
        "userType": "regular", // تحديد نوع المستخدم
        "createdAt": DateTime.now(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.code} - ${e.message}");
      if (e.code == 'email-already-in-use') {
        throw Exception("The email is already in use");
      } else if (e.code == 'weak-password') {
        throw Exception("Password is too weak");
      } else if (e.code == 'invalid-email') {
        throw Exception("The email address is invalid");
      } else {
        throw Exception("Error during signup: ${e.message}");
      }
    }
  }

  // sign up expert user
  Future<UserCredential> signUpExpertWithEmailAndPassword(
    String email,
    String password,
    Map<String, dynamic> expertData, // بيانات إضافية للخبير
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      print("Expert successfully registered: ${userCredential.user?.email}");

      // after creating the expert, add to experts collection
      await _firestore.collection("experts").doc(userCredential.user!.uid).set({
        "email": email,
        "uid": userCredential.user!.uid,
        "userType": "expert", // تحديد نوع المستخدم
        "createdAt": DateTime.now(),
        ...expertData, // تضمين البيانات الإضافية للخبير
      });

      // يمكنك أيضًا إضافته إلى مجموعة users العامة إذا كنت تريد ذلك
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "email": email,
        "uid": userCredential.user!.uid,
        "userType": "expert",
        "createdAt": DateTime.now(),
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.code} - ${e.message}");
      if (e.code == 'email-already-in-use') {
        throw Exception("The email is already in use");
      } else if (e.code == 'weak-password') {
        throw Exception("Password is too weak");
      } else if (e.code == 'invalid-email') {
        throw Exception("The email address is invalid");
      } else {
        throw Exception("Error during expert signup: ${e.message}");
      }
    }
  }

  // get current user type
  Future<String?> getUserType(String uid) async {
    DocumentSnapshot userDoc =
        await _firestore.collection("users").doc(uid).get();
    return userDoc.get("userType");
  }

  // get expert data (if user is expert)
  Future<Map<String, dynamic>?> getExpertData(String uid) async {
    DocumentSnapshot expertDoc =
        await _firestore.collection("experts").doc(uid).get();
    if (expertDoc.exists) {
      return expertDoc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // sign user out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

// Récupérer les informations du profil de l'utilisateur
Future<Map<String, dynamic>?> getUserProfile(
    String uid, FirebaseFirestore firestore) async {
  try {
    DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    return null;
  } catch (e) {
    print("Error retrieving user profile: $e");
    return null;
  }
}

