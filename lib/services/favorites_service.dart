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
}
