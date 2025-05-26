import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// === CONFIG CLOUDINARY ===
const String cloudName = 'dqlvshdhp'; // Remplace par ton cloud name Cloudinary
const String uploadPreset =
    'algrinova_upload'; // Remplace par ton upload preset Cloudinary

Future<String?> uploadImageToCloudinary(File imageFile) async {
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );

  final request =
      http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final data = json.decode(responseBody);
    return data['secure_url']; // URL publique de l'image
  } else {
    print('Erreur upload Cloudinary : ${response.statusCode}');
    return null;
  }
}

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Récupérer tous les posts de tous les utilisateurs, triés par timestamp décroissant
// Récupérer tous les posts de tous les utilisateurs, triés par timestamp décroissant
Stream<List<Map<String, dynamic>>> getAllPosts() {
  return _firestore
      .collection('allPosts')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['postId'] = doc.id;
          return data;
        }).toList();
      });
}


Future<void> syncAllPostsToGlobalCollection() async {
  try {
    final allUserPostsSnapshots = await _firestore
        .collectionGroup('userPosts')
        .get();

    for (final doc in allUserPostsSnapshots.docs) {
      final postData = doc.data();
      final postId = doc.id;

      // Ajoute aussi l'UID de l'utilisateur si ce n'est pas déjà dedans
      if (!postData.containsKey('userId')) {
        final userIdFromPath = doc.reference.path.split('/')[1];
        postData['userId'] = userIdFromPath;
      }

      await _firestore.collection('allPosts').doc(postId).set(postData);
    }

    print("✅ Tous les posts ont été copiés vers allPosts.");
  } catch (e) {
    print("❌ Erreur lors de la synchronisation vers allPosts : $e");
  }
}


  // Stream<List<Map<String, dynamic>>> getUserPosts(String userId) {
  //   return _firestore
  //       .collection('posts')
  //       .doc(userId)
  //       .collection('userPosts')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map(
  //         (snapshot) =>
  //             snapshot.docs
  //                 .map((doc) => doc.data() as Map<String, dynamic>)
  //                 .toList(),
  //       );
  // }

  Future<void> toggleLike(String ownerId, String postId, String userId) async {
    DocumentReference postRef = _firestore
        .collection('posts')
        .doc(userId)
        .collection('userPosts')
        .doc(postId);

    DocumentSnapshot postSnapshot = await postRef.get();
    List<dynamic> currentLikes = (postSnapshot.data() as Map<String, dynamic>?)?['likes'] ?? [];

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
    final commentRef =
        _firestore
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
    final postRef = _firestore
        .collection('posts')
        .doc(ownerId)
        .collection('userPosts')
        .doc(postId);
    await postRef.update({'comments': FieldValue.increment(1)});
  }

  // Récupérer les commentaires d'un post (stream)
  Stream<List<Map<String, dynamic>>> getComments(
    String ownerId,
    String postId,
  ) {
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

      String photoUrl =
          userData['photoUrl'] ??
          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
      String name = userData['name'] ?? 'Nom inconnu';
      String location = userData['location'] ?? 'Inconnu';

      final postId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = Timestamp.now(); // 🔥 Toujours présent, pas null

      await _firestore
          .collection('posts')
          .doc(uid)
          .collection('userPosts')
          .doc(postId)
          .set({
            'caption': caption,
            'hashtag': hashtag,
            'imageUrl': imageUrl,
            'likes': [0],
            'timestamp': now,
            'comments': 0,
            'shares': 0,
            'userId': uid,
            'location': location,
            'photoUrl': photoUrl,
            'name': name,
            'postId': postId,
          });
    await syncAllPostsToGlobalCollection();
  } catch (e) {
    print('Erreur lors de la publication du post : $e');
    rethrow;
  }
  }
}
