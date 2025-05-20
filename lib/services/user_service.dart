import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path; // Ajouté

class UserService {
  final _usersCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> saveUser(User user) async {
    try {
      await _usersCollection.doc(user.uid).set({
        'name': user.displayName ?? 'Nom inconnu',
        'email': user.email,
        'role': 'utilisateur',
        'bio': '',
        'photoUrl': user.photoURL ?? '',
      }, SetOptions(merge: true));
    } catch (e) {
      print("Erreur lors de l'enregistrement de l'utilisateur : $e");
      rethrow;
    }
  }

  Future<void> updateUserProfileWithImage({
    required String uid,
    required Map<String, dynamic> data,
    required File? imageFile,
  }) async {
    try {
      String? photoUrl;

      if (imageFile != null) {
        final fileExtension = path.extension(imageFile.path);
        final storageRef = _storage
            .ref()
            .child('profile_pictures/$uid$fileExtension');

        print("⏫ Uploading image to: ${storageRef.fullPath}");
        await storageRef.putFile(imageFile);
        photoUrl = await storageRef.getDownloadURL();
        print("✅ URL téléchargée : $photoUrl");
      }

      await _usersCollection.doc(uid).update({
        ...data,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });
    } catch (e) {
      print("❌ Erreur dans updateUserProfileWithImage : $e");
      rethrow;  // <— on remonte l'erreur d'origine
    }
  }


  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _usersCollection.doc(uid).get();
  }
}
