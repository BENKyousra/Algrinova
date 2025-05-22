import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algrinova/services/user_service.dart';
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

     final user = userCredential.user;     
    if (user != null) {
      await UserService().updateOnlineStatus(user.uid, true);  // <-- Mise à jour en ligne
    }

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
    // Étape 1 : Créer l'utilisateur avec Firebase Auth
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    
    print("✅ Compte créé : ${userCredential.user?.email}");

    // Étape 2 : Enregistrer l'utilisateur dans Firestore via UserService
    final user = userCredential.user;
    if (user != null) {
      await UserService().saveUser(user);
    }

    return userCredential;
  } on FirebaseAuthException catch (e) {
    print("❌ Erreur Auth : ${e.code} - ${e.message}");
    if (e.code == 'email-already-in-use') {
      throw Exception("Cet e-mail est déjà utilisé");
    } else if (e.code == 'weak-password') {
      throw Exception("Mot de passe trop faible");
    } else if (e.code == 'invalid-email') {
      throw Exception("Adresse e-mail invalide");
    } else {
      throw Exception("Erreur pendant l'inscription : ${e.message}");
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
    final user = _firebaseAuth.currentUser;
  if (user != null) {
    await UserService().updateOnlineStatus(user.uid, false);  // <-- Mise à jour hors ligne
  }
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

