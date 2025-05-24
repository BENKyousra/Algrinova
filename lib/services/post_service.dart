import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// === CONFIG CLOUDINARY ===
const String cloudName = 'dqlvshdhp';          // Remplace par ton cloud name Cloudinary
const String uploadPreset = 'algrinova_upload'; // Remplace par ton upload preset Cloudinary

Future<String?> uploadImageToCloudinary(File imageFile) async {
  final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final data = json.decode(responseBody);
    return data['secure_url'];  // URL publique de l'image
  } else {
    print('Erreur upload Cloudinary : ${response.statusCode}');
    return null;
  }
}

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getAllPosts() {
    return _firestore.collection('posts').snapshots().asyncMap((snapshot) async {
      List<Map<String, dynamic>> allPosts = [];

      for (var userDoc in snapshot.docs) {
        final postsSnap = await userDoc.reference.collection('userPosts').orderBy('timestamp', descending: true).get();

        for (var post in postsSnap.docs) {
          final postData = post.data();
          postData['postId'] = post.id;
          postData['uid'] = userDoc.id;
          allPosts.add(postData);
        }
      }

      return allPosts;
    });
  }
  

   Future<void> toggleLike(String ownerId, String postId, String userId) async {
    DocumentReference postRef = _firestore.collection('posts').doc(ownerId).collection('userPosts').doc(postId);

    DocumentSnapshot postSnapshot = await postRef.get();
    List<dynamic> currentLikes = postSnapshot.get('likes') ?? [];

    if (currentLikes.contains(userId)) {
      // Déjà liké → supprimer l'UID
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      // Pas encore liké → ajouter l'UID
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

 Future<void> addComment({
    required String ownerId,
    required String postId,
    required String userId,
    required String name,
    required String photoUrl,
    required String text,
  }) async {
    final commentRef = _firestore
      .collection('posts')
      .doc(ownerId)
      .collection('userPosts')
      .doc(postId)
      .collection('comments')
      .doc(); // ID auto généré

    await commentRef.set({
      'commentId': commentRef.id,
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Optionnel : incrémenter le compteur de commentaires dans le post
    final postRef = _firestore.collection('posts').doc(ownerId).collection('userPosts').doc(postId);
    await postRef.update({
      'comments': FieldValue.increment(1),
    });
  }

  // Récupérer les commentaires d'un post (stream)
  Stream<List<Map<String, dynamic>>> getComments(String ownerId, String postId) {
    return _firestore
      .collection('posts')
      .doc(ownerId)
      .collection('userPosts')
      .doc(postId)
      .collection('comments')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> publishPost({
    required String caption,
    required String hashtag,
    String? imageUrl, 
  }) async {
    try {
     

      // Récupérer données utilisateur
      String uid = _auth.currentUser!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      String photoUrl = userData['photoUrl'] ?? 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
      String name = userData['name'] ?? 'Nom inconnu';
      String location = userData['location'] ?? 'Inconnu';

      // Ajouter le post dans Firestore
      await _firestore.collection('posts').doc(uid).collection('userPosts').add({
        'caption': caption,
        'hashtag': hashtag,
        'imageUrl': imageUrl ?? '',
        'likes': [],
        'timestamp': FieldValue.serverTimestamp(),
        'comments': 0,
        'shares': 0,
        'userId': uid,
        'location': location,
        'photoUrl': photoUrl,
        'name': name,
      });

    } catch (e) {
      print('Erreur lors de la publication du post : $e');
      rethrow;
    }
  }
  
}
