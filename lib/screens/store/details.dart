import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:algrinova/models/product.dart';
import 'package:provider/provider.dart';
import 'package:algrinova/provider/cart_provider.dart';

// صفحة التفاصيل التي تعرض معلومات منتج معين وتعليمات العناية به
class Details extends StatefulWidget {
  final Product product; // المنتج المُراد عرضه
  final List<String> careInstructions; // تعليمات العناية

  const Details({
    super.key,
    required this.product,
    required this.careInstructions,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int quantity = 1; // الكمية التي يحددها المستخدم
  static const Color primaryTextColor = Color(0xFFD0FFD0); // لون النص الأساسي
  static const BoxShadow buttonShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 6,
    offset: Offset(0, 3),
  );

  // إعداد واجهة النظام بعد بناء الواجهة
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setSystemUIOverlay();
    });
  }

  // إعداد شفافية شريط الحالة وأيقونات النظام
  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  // شريط التطبيق المخصص بالأعلى
  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // زر الرجوع
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        // شعار التطبيق
        const Row(
          children: [
            Icon(Icons.eco_rounded, color: Colors.green, size: 28),
            SizedBox(width: 6),
            Text(
              "Algrinova",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Lobster',
                fontSize: 26,
              ),
            ),
          ],
        ),
        // مساحة فارغة لموازنة التصميم
        const SizedBox(width: 48),
      ],
    );
  }

  // عنصر التحكم في الكمية (زيادة ونقصان)
  Widget _buildQuantityController() {
    return Row(
      children: [
        _buildQuantityButton(Icons.remove, () {
          setState(() => quantity = quantity > 1 ? quantity - 1 : 1);
        }),
        const SizedBox(width: 8),
        Text(
          '$quantity',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        _buildQuantityButton(Icons.add, () => setState(() => quantity++)),
      ],
    );
  }

  // زر التحكم في الكمية مع تأثير الظل
  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [buttonShadow],
      ),
      child: IconButton(
        icon: Icon(icon),
        splashRadius: 20,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final careList = widget.careInstructions;

    return Scaffold(
      backgroundColor: Colors.white10,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 23, vertical: 70),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 143, 48),
                Color.fromARGB(255, 0, 41, 14),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(), // شريط العنوان
                const SizedBox(height: 8),

                // اسم المنتج
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                    fontFamily: 'Righteous',
                  ),
                ),
                const SizedBox(height: 10),

                // وصف المنتج
                Text(
                  product.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // عنوان تعليمات العناية
                const Text(
                  "Care",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                    fontFamily: 'Righteous',
                  ),
                ),
                const SizedBox(height: 10),

                // قائمة تعليمات العناية
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      careList
                          .map(
                            (text) => _CareItem(
                              icon: _getIconForCare(text),
                              text: text,
                            ),
                          )
                          .toList(),
                ),

                const Spacer(),

                // السعر وأداة تحديد الكمية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${product.price.toStringAsFixed(0)} DA",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildQuantityController(),
                  ],
                ),

                const SizedBox(height: 50),

                // أزرار المفضلة والإضافة إلى السلة
                Row(
                  children: [
                    // زر المفضلة
                    Container(
                      height: 58,
                      width: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [buttonShadow],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 20),

                    // زر الإضافة إلى السلة
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          final cart = Provider.of<CartProvider>(
                            context,
                            listen: false,
                          );

                          cart.addToCart(widget.product, quantity);

                          _showTransparentDialog(context);
                        },

                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Add to cart", style: TextStyle(fontSize: 18)),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // اختيار الأيقونة المناسبة حسب نوع تعليمات العناية
  IconData _getIconForCare(String text) {
    if (text.toLowerCase().contains("water")) return Icons.water_drop;
    if (text.toLowerCase().contains("°") || text.contains("°C"))
      // ignore: curly_braces_in_flow_control_structures
      return Icons.thermostat;
    if (text.toLowerCase().contains("light")) return Icons.light_mode_outlined;
    return Icons.eco;
  }

  // نافذة منبثقة شفافة تظهر بعد الإضافة إلى السلة
  void _showTransparentDialog(BuildContext context) {
    showDialog(
      context: context,
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.5),
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.85),
                ),
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Added to the cart",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "The product has been successfully added to your shopping cart",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 41, 14),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Okay",
                        style: TextStyle(fontSize: 18, color: Colors.white),
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

// عنصر واجهة لعرض بند من تعليمات العناية
class _CareItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CareItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
