import 'package:algrinova/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  List<CartItem> get items => _items.values.toList();
  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem(ProductModel product) {
  print('Ajout au panier : ${product.name} - ID = ${product.id}');

  if (_items.containsKey(product.id)) {
    _items.update(
      product.id,
      (existingItem) => CartItem(
        product: existingItem.product,
        quantity: existingItem.quantity + 1,
      ),
    );
  } else {
    _items.putIfAbsent(
      product.id,
      () => CartItem(
        product: product,
        quantity: 1,
      ),
    );
  }
  notifyListeners();
}


  // في ملف cart_provider.dart
  void removeItem(String productId) {
    _items.removeWhere(
      (key, cartItem) => cartItem.product.id.toString() == productId,
    );
    notifyListeners();
  }

  Future<void> fetchCartFromFirestore(String userId) async {
    final cartRef = FirebaseFirestore.instance.collection('carts').doc(userId);
    final doc = await cartRef.get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['items'] != null) {
        final itemsMap = Map<String, dynamic>.from(data['items']);

        _items = itemsMap.map((key, value) {
          final product = ProductModel(
            id: value['productId'],
            name: value['productName'],
            price: value['price'],
            imageUrls: List<String>.from(value['imageUrls']),
            careInstructions:
                value['careInstructions'] ??
                '', // Provide a default or fetch from Firestore
            // Ajoute d’autres champs si besoin
          );

          return MapEntry(
            key,
            CartItem(product: product, quantity: value['quantity']),
          );
        });

        notifyListeners();
      }
    }
  }

  Future<void> saveCartToFirestore(String userId) async {
    final cartRef = FirebaseFirestore.instance.collection('carts').doc(userId);

    final itemsMap = _items.map(
      (key, cartItem) => MapEntry(key, {
        'productId': cartItem.product.id,
        'productName': cartItem.product.name,
        'price': cartItem.product.price,
        'quantity': cartItem.quantity,
        'imageUrls': cartItem.product.imageUrls,
      }),
    );

    await cartRef.set({'items': itemsMap});
    notifyListeners();
  }
}
