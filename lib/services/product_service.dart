import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference productCollection =
      FirebaseFirestore.instance.collection('product');

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      QuerySnapshot snapshot = await productCollection.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Erreur récupération produits: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsByCategory(String category) async {
  QuerySnapshot snapshot;

  if (category == 'All') {
    snapshot = await FirebaseFirestore.instance.collection('products').get();
  } else {
    snapshot = await FirebaseFirestore.instance
        .collection('product')
        .where('category', isEqualTo: category)
        .get();
  }

  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return data;
  }).toList();
}


}
