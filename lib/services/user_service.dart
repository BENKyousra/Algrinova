import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Enregistre un utilisateur dans Firestore
  Future<void> saveUser(User user) async {
    try {
      await _usersCollection.doc(user.uid).set({
        'name': user.displayName ?? 'Nom inconnu',
        'email': user.email,
        'role': 'user', // par défaut, role = user
        'bio': '',
        'photoUrl': user.photoURL ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        'isOnline': false, 
        'location': 'Inconnu',
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Erreur lors de l'enregistrement de l'utilisateur : $e");
      rethrow;
    }
  }

  /// Met à jour le profil utilisateur avec ou sans image
  Future<void> updateUserProfileWithImage({
  required String uid,
  required Map<String, dynamic> data,
  File? imageFile,
}) async {
  try {
    if (imageFile != null) {
      final storageRef = _storage.ref().child('profile_pictures/$uid.jpg');
      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();
      data['photoUrl'] = imageUrl;
    }

    await _usersCollection.doc(uid).update(data);

    print("✅ Profil mis à jour avec succès");
  } catch (e, stacktrace) {
    print("❌ Erreur dans updateUserProfileWithImage : $e");
    print("🧱 Stacktrace : $stacktrace");
    rethrow;
  }
}

  /// Récupère les infos du profil utilisateur
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _usersCollection.doc(uid).get();
  }

  /// Récupère le rôle d'un utilisateur ('user', 'expert', etc.)
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()! as Map<String, dynamic>;
        return data['role'] ?? 'user';
      } else {
        return 'user';
      }
    } catch (e) {
      print("❌ Erreur dans getUserRole : $e");
      return 'user';
    }
  }

 Future<void> updateOnlineStatus(String userId, bool isOnline) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'isOnline': isOnline,
  });
}

 Future<void> deleteUser({required String password}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-user', message: 'Utilisateur non connecté');

    // Crée les credentials pour la ré-authentification
    final credential = EmailAuthProvider.credential(email: user.email!, password: password);

    // Étape 1 : ré-authentification
    await user.reauthenticateWithCredential(credential);

    // // Étape 2 : suppression du document Firestore
    await _usersCollection.doc(user.uid).delete();

    // Étape 3 : suppression du compte Firebase Auth
    await user.delete();

    // Étape 4 : déconnexion
    await FirebaseAuth.instance.signOut();
  }


  Future<Map<String, dynamic>> getCurrentUserInfo() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.data()!;
}

}
