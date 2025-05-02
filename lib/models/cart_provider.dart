import 'package:flutter/material.dart';
import '../../models/product.dart'; // تأكد من مسار استيراد Product
import '../../models/cart_item.dart'; // سننشئه أيضًا

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(Product product, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // في ملف cart_provider.dart
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id.toString() == productId);
    notifyListeners();
  }
}
