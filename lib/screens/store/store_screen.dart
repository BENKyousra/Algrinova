// استيراد الحزم اللازمة
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:algrinova/screens/store/details.dart'; // تأكد من أن المسار صحيح
import 'package:algrinova/models/product.dart';
import 'package:group_button/group_button.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'cart_screen.dart'; // Ensure this file contains the CartScreen class
import 'package:algrinova/widgets/custom_bottom_navbar.dart';

// تعريف واجهة الصفحة الرئيسية
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  // عناصر التحكم في التمرير وظهور الأدوات
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = true;
  final GroupButtonController _groupController = GroupButtonController();
  bool _showGroupButtons = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().startsWith(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // قائمة المنتجات
  final List<Product> products = [
    Product(
      id: 1,
      name: "Lavender",
      price: 1500,
      image: "assets/images/roses.jpg",
      description:
          "Lavender is a fragrant plant known for its calming properties.",
      careInstructions: [
        "Water every 7 days",
        "18–25°C",
        "Does not like light",
      ],
      category: "Plants",
    ),
    Product(
      id: 2,
      name: "Monstera",
      price: 800,
      image: "assets/images/rose seed.jpg",
      description: "Monstera is a tropical plant with unique split leaves.",
      careInstructions: [
        "Water every 7 days",
        "18–25°C",
        "Does not like light",
      ],
      category: "Plants",
    ),
    Product(
      id: 3,
      name: "Rose seed",
      price: 1500,
      image: "assets/images/rose seed.jpg",
      description: "Lemon trees produce citrus fruit rich in vitamin C.",
      careInstructions: [
        "Water every 7 days",
        "18–25°C",
        "Does not like light",
      ],
      category: "Seeds",
    ),
    Product(
      id: 4,
      name: "Olive",
      price: 800,
      image: "assets/images/roses.jpg",
      description: "Olive trees are known for their fruit and oil.",
      careInstructions: [
        "Water every 7 days",
        "18–25°C",
        "Does not like light",
      ],
      category: "Seedlings",
    ),
    Product(
      id: 5,
      name: "Roses",
      price: 2000,
      image: "assets/images/roses.jpg",
      description: "Roses is a lovely plant known for its calming properties.",
      careInstructions: [
        "Water every 7 days",
        "18–25°C",
        "Does not like light",
      ],
      category: "Plants",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // تعيين "All" كمحدد افتراضي
    _selectedCategory = 'All'; // تأكد من أن هذه القيمة مطابقة للزر في القائمة
    // تحديد الزر الأول (All)
    // إخفاء المؤشر عند الضغط على زر الرجوع
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _searchQuery = '';
        });
      }
    });
    // التحكم في إظهار/إخفاء الرأس حسب اتجاه التمرير
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse &&
          _isVisible) {
        setState(() => _isVisible = false);
      } else if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          !_isVisible) {
        setState(() => _isVisible = true);
      }
    });

    // التحكم في ظهور أزرار التصنيفات
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showGroupButtons) setState(() => _showGroupButtons = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showGroupButtons) setState(() => _showGroupButtons = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: 3,
      ),
      extendBody: true,
      // محتوى الصفحة
      body: Stack(
        children: [
          Column(
            children: [
              // رأس منحني مع تأثير متحرك
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isVisible ? 155 : 0,
                child: _buildCurvedHeader(),
              ),

              _buildGroupButtons(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 0,
                  ),
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GestureDetector(
                        onTap: () => _showProductDetails(context, product),
                        child: _buildProductCard(product),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // شريط البحث العائم
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _isVisible ? 95 : -50,
            left: 20,
            right: 20,
            child: _buildSearchBar(),
          ),
          // زر السلة العائم
          Positioned(
            bottom: 80,
            right: 20,
            child: Container(
              width: 56, // نفس حجم FloatingActionButton الافتراضي
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 143, 48),
                    Color.fromARGB(255, 0, 41, 14),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupButtons() {
    if (!_showGroupButtons) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: GroupButton(
          controller: _groupController,
          isRadio: true,
          buttons: const [
            'All',
            'Seeds',
            'Seedlings',
            'Accessories',
            'Tools',
            'Plants',
            'Soil',
            'Fertilizers',
          ],
          onSelected: (text, index, isSelected) {
            setState(() {
              _selectedCategory = text;
            });
          },
          options: GroupButtonOptions(
            borderRadius: BorderRadius.circular(20),
            spacing: 8,
            selectedTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            selectedColor: Colors.black,
            unselectedTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            unselectedColor: Color.fromARGB(255, 217, 217, 217),
          ),
        ),
      ),
    );
  }

  // دالة لعرض بطاقة المنتج
  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 1, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المنتج مع إمكانية عرضها بالحجم الكامل
          Expanded(
            child: GestureDetector(
              onTap: () => _showZoomImage(context, product.image),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.asset(
                  product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),

          // معلومات المنتج + زر الإضافة إلى السلة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontFamily: 'QuickSand',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 143, 48),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${product.price} DA',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: GestureDetector(
                    onTap: () => _showProductDetails(context, product),
                    child: Icon(
                      Icons.add_shopping_cart,
                      color: Color.fromARGB(255, 0, 143, 48),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دالة عرض تفاصيل المنتج
  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Details(
            product: product,
            careInstructions: product.careInstructions,
          ),
    );
  }

  // عرض الصورة بالحجم الكامل
  void _showZoomImage(BuildContext context, String imagePath) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Image Zoom",
      // ignore: deprecated_member_use
      barrierColor: Colors.black.withOpacity(0.8), // خلفية شفافة داكنة
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(), // إغلاق عند الضغط
          child: Center(
            child: InteractiveViewer(child: Image.asset(imagePath)),
          ),
        );
      },
    );
  }

  // شريط البحث
  Widget _buildSearchBar() {
    return Container(
      width: 300,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 143, 48),
            Color.fromARGB(255, 0, 41, 14),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        focusNode: _searchFocusNode,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.white, fontFamily: 'QuickSand'),
        decoration: const InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white),
        ),
      ),
    );
  }

  // Widget _buildGroupButtons() {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     height: _showGroupButtons ? 50 : 0,
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
  //       child: SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         child: GroupButton(
  //           controller: _groupController,
  //           isRadio: true,
  //           buttons: const [
  //             'All',
  //             'Seeds',
  //             'Seedlings',
  //             'Accessories',
  //             'Tools',
  //             'Plants',
  //             'Soil',
  //             'Fertilizers',
  //           ],
  //           onSelected: (text, index, isSelected) {
  //             setState(() {
  //               _selectedCategory = text;
  //             });
  //           },

  //           options: GroupButtonOptions(
  //             borderRadius: BorderRadius.circular(20),
  //             spacing: 8,
  //             selectedTextStyle: const TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.white,
  //             ),
  //             selectedColor: Colors.black,
  //             unselectedTextStyle: const TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black,
  //             ),
  //             unselectedColor:  Color.fromARGB(255, 206, 206, 206),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // رأس الصفحة المنحني
  Widget _buildCurvedHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            height: 170,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/blur.png"),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 25,
          child: Row(
            children: const [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.eco_rounded, color: Colors.green),
              ),
              SizedBox(width: 10),
              Text(
                "Algrinova",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lobster',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 154,
          left: 0,
          right: 0,
          child: Container(
            height: 1.0,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 145, 145, 145),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 0.9,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// كلاس مخصص لقص رأس الصفحة بشكل منحني
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.9);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 1.05,
      size.width * 0.6,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
