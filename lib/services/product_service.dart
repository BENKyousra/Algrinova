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
}
