import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/cart_provider.dart';
import '../../models/cart_item.dart';
import 'payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await cart.fetchCartFromFirestore(userId);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
   final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items;


    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              title: Text(
                'Shopping cart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              flexibleSpace: Image.asset(
                'assets/images/blur.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
        ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, cartItems),
    );
  }

  Widget _buildBody(BuildContext context, List<CartItem> cartItems) {
    return cartItems.isEmpty
        ? _buildEmptyCart()
        : Column(
          children: [
            _buildCartItemsList(cartItems),
            if (cartItems.isNotEmpty) _buildTotalPriceSection(context),
          ],
        );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Text("Your cart is empty 🛒", style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildCartItemsList(List<CartItem> cartItems) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cartItems.length,
        itemBuilder:
            (context, index) => _buildCartItemCard(context, cartItems[index]),
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // ✅ صورة المنتج باستخدام Image.asset مباشرة
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.product.imageUrls[0],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${item.quantity} x ${item.product.price} DA",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    "${item.totalPrice.toStringAsFixed(0)} DA",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 143, 48),
                    ),
                  ),
                ),
              ],
            ),

            // ✅ أيقونة الحذف بشكل أنعم وأسرع في الظهور
            Positioned(
              top: -10,
              right: -10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  bool confirmDelete = await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Remove Item"),
                          content: const Text(
                            "Are you sure you want to remove this item from your cart?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Remove",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirmDelete == true) {
                    final cart = Provider.of<CartProvider>(
                      // ignore: use_build_context_synchronously
                      context,
                      listen: false,
                    );
                    cart.removeItem(item.product.id.toString());

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Item removed from cart",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPriceSection(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // مهم لجعل التدرج يظهر
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 5,
          // ignore: deprecated_member_use
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(totalPrice: cart.totalPrice),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 143, 48),
                Color.fromARGB(255, 0, 41, 14),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 19),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Pay ", style: TextStyle(fontSize: 25)),
                Text(
                  "(${cart.totalPrice.toStringAsFixed(0)} DA)",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
