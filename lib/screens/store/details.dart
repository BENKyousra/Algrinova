import 'package:algrinova/provider/cart_provider.dart';
import 'package:algrinova/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart'; // ajoute ça dans pubspec.yaml
import 'package:algrinova/services/favorites_service.dart';

class Details extends StatefulWidget {
  final ProductModel product;
  final List<String> careInstructions;

  Details({
    super.key,
    required this.product,
    required this.careInstructions,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int _currentImageIndex = 0;
  final FavoritesService _favoritesService = FavoritesService();

  bool _isLiked = false;

 @override
  void initState() {
    super.initState();
    _checkLiked();
  }

  Future<void> _checkLiked() async {
    bool liked = await _favoritesService.isProductLiked(widget.product.id);
    setState(() {
      _isLiked = liked;
    });
  }

  void _toggleLike() async {
    await _favoritesService.toggleLikeProduct(widget.product);
    bool liked = await _favoritesService.isProductLiked(widget.product.id);
    setState(() {
      _isLiked = liked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              title: Text(
                'Product Details',
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
              actions: [
  IconButton(
    icon: Icon(
      _isLiked ? Icons.favorite : Icons.favorite_border,
      color: _isLiked ? Color.fromARGB(255, 255, 47, 92)
                                    : Color.fromRGBO(80, 80, 80, 1),
    ),
      onPressed: _toggleLike,
  ),
],

            ),
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Galerie d'images =====
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: widget.product.imageUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = widget.product.imageUrls[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageGallery(
                            images: widget.product.imageUrls,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
             if (widget.product.imageUrls.length > 1)
                    Positioned(
                      bottom: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.product.imageUrls.length,
                          (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 12 : 8,
                            height: _currentImageIndex == index ? 12 : 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? const Color.fromARGB(255, 0, 0, 0)
                                  :Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
            const SizedBox(height: 16),

            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF008F30),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.product.price.toStringAsFixed(2)} DA',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.product.description ?? '',
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 20),

            if (widget.careInstructions.isNotEmpty) ...[
              const Text(
                "Conseils d'entretien",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.careInstructions.map((instruction) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text(instruction)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                 onPressed: () {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    cartProvider.addItem(widget.product); // Ajoute le produit au panier

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} ajouté au panier'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  },
                label: Text("Add to Cart", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _controller;
  int _currentImageIndex = 0;


  @override
  void initState() {
    _controller = PageController(initialPage: widget.initialIndex);
    _currentImageIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
  alignment: Alignment.bottomCenter,
  children: [
    PageView.builder(
      controller: _controller,
      itemCount: widget.images.length,
      onPageChanged: (index) {
        setState(() {
          _currentImageIndex = index;
        });
      },
      itemBuilder: (_, index) {
        return Center(
          child: PhotoView(
            imageProvider: NetworkImage(widget.images[index]),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained * 1,
            maxScale: PhotoViewComputedScale.covered * 2.5,
          ),
        );
      },
    ),
    // ✅ Indicateur de page (points en bas)
    Positioned(
      bottom: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.images.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentImageIndex == index ? 12 : 8,
            height: _currentImageIndex == index ? 12 : 8,
            decoration: BoxDecoration(
              color: _currentImageIndex == index
                  ? Colors.green
                  : Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    )
  ],
),

    );
  }
}
