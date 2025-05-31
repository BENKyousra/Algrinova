import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algrinova/screens/store/store_screen.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Toggle like/unlike pour un produit
  Future<void> toggleLikeProduct(ProductModel product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final itemRef = _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('likedItems')
        .doc(product.id);

    final docSnapshot = await itemRef.get();

    if (docSnapshot.exists) {
      await itemRef.delete();
    } else {
      await itemRef.set({
        'type': 'product',
        'name': product.name,
        'imageUrl': product.imageUrls.first,
        'price': product.price,
        'likedAt': Timestamp.now(),
        'productId': product.id,
        'description': product.description ?? '',
        'careInstructions': product.careInstructions ?? '',

      });
    }
  }

  // Vérifier si le produit est liké
  Future<bool> isProductLiked(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('likedItems')
        .doc(productId)
        .get();

    return doc.exists;
  }

// ------------------------------------------------------------------------------------

// Future<void> addPostToLiked({
//   required String userId,
//   required String postId,
//   required String ownerId,
//   required Map<String, dynamic> postData,
// }) async {
//   final docRef = FirebaseFirestore.instance
//       .collection('favorites')
//       .doc(userId)
//       .collection('likedPosts')
//       .doc(postId);

//   await docRef.set({
//     'ownerId': ownerId,
//     'caption': postData['caption'] ?? '',
//     'hashtag': postData['hashtag'] ?? '',
//     'imageUrl': postData['imageUrl'] ?? '',
//     'likes': postData['likes'] ?? [],
//     'timestamp': Timestamp.now(),
//     'comments': postData['comments'] ?? 0,
//     'shares': postData['shares'] ?? 0,
//     'userId': userId,
//     'location': postData['location'] ?? '',
//     'photoUrl': postData['photoUrl'] ?? '',
//     'name': postData['name'] ?? '',
//     'postId': postId,
//     'likedAt': Timestamp.now(),
//   });
// }

// Future<void> removePostFromLiked({
//   required String userId,
//   required String postId,
// }) async {
//   final docRef = FirebaseFirestore.instance
//       .collection('favorites')
//       .doc(userId)
//       .collection('likedPosts')
//       .doc(postId);

//   await docRef.delete();
// }


Future<void> syncLikedPostsToFavorites() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.uid;
  final firestore = FirebaseFirestore.instance;

  final allPostsSnapshot = await firestore.collection('posts').get();

  for (var userDoc in allPostsSnapshot.docs) {
    final userPostsSnapshot = await firestore
        .collection('posts')
        .doc(user.uid)
        .collection('userPosts')
        .get();

    for (var postDoc in userPostsSnapshot.docs) {
      final postData = postDoc.data();
      final List<dynamic> likes = postData['likes'] ?? [];

      if (likes.contains(uid)) {
        // L'utilisateur a liké ce post
        final likedPostRef = firestore
            .collection('favorites')
            .doc(uid)
            .collection('likedPosts')
            .doc(postDoc.id);

        final ownerId = postData['ownerId'] ?? '';
        final userId = uid;
        final postId = postDoc.id;

        await likedPostRef.set({
          'ownerId': ownerId,
          'caption': postData['caption'] ?? '',
          'hashtag': postData['hashtag'] ?? '',
          'imageUrl': postData['imageUrl'] ?? '',
          'likes': postData['likes'] ?? [],
          'timestamp': Timestamp.now(),
          'comments': postData['comments'] ?? 0,
          'shares': postData['shares'] ?? 0,
          'userId': userId,
          'location': postData['location'] ?? '',
          'photoUrl': postData['photoUrl'] ?? '',
          'name': postData['name'] ?? '',
          'postId': postId,
          'likedAt': FieldValue.serverTimestamp(), // pour trier
        });
      }
    }
  }
}

  //  Future<void> toggleLikePost(String postId, Map<String, dynamic> postData) async {
  //   final user = _auth.currentUser;
  //   if (user == null) return;

  //   final itemRef = _firestore
  //       .collection('favorites')
  //       .doc(user.uid)
  //       .collection('likedPosts')
  //       .doc(postId);

  //   final docSnapshot = await itemRef.get();

  //   if (docSnapshot.exists) {
  //     await itemRef.delete();
  //   } else {
  //     await itemRef.set({
  //           'caption': postData['caption'] ?? '',
  //           'hashtag': postData['hashtag'] ?? '',
  //           'imageUrl': postData['imageUrl'] ?? '',
  //           'likes': postData['likes'] ?? [],
  //           'timestamp': Timestamp.now(),
  //           'comments': postData['comments'] ?? 0,
  //           'shares': postData['shares'] ?? 0,
  //           'userId': user.uid,
  //           'location': postData['location'] ?? '',
  //           'photoUrl': postData['photoUrl'] ?? '',
  //           'name': postData['name'] ?? '',
  //           'postId': postId,
  //       // ajoute d'autres champs utiles si besoin
  //     });
  //   }
  // }

  // // Vérifier si le post est liké
  // Future<bool> isPostLiked(String postId) async {
  //   final user = _auth.currentUser;
  //   if (user == null) return false;

  //   final doc = await _firestore
  //       .collection('favorites')
  //       .doc(user.uid)
  //       .collection('likedPosts')
  //       .doc(postId)
  //       .get();

  //   return doc.exists;
  // }

  // Future<void> removePostFromFavorites(String userId, String postId) async {
  //   await _firestore
  //       .collection('favorites')
  //       .doc(userId)
  //       .collection('likedPosts')
  //       .doc(postId)
  //       .delete();
  // }

  //  Future<void> addPostToFavorites(String userId, String postId, Map<String, dynamic> postData) async {
  //   await _firestore
  //       .collection('favorites')
  //       .doc(userId)
  //       .collection('likedPosts')
  //       .doc(postId)
  //       .set({
  //         'caption': postData['caption'] ?? '',
  //           'hashtag': postData['hashtag'] ?? '',
  //           'imageUrl': postData['imageUrl'] ?? '',
  //           'likes': postData['likes'] ?? [],
  //           'timestamp': Timestamp.now(),
  //           'comments': postData['comments'] ?? 0,
  //           'shares': postData['shares'] ?? 0,
  //           'userId': userId,
  //           'location': postData['location'] ?? '',
  //           'photoUrl': postData['photoUrl'] ?? '',
  //           'name': postData['name'] ?? '',
  //           'postId': postId,
  //       });
  // }
}
