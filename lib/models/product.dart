// models/product.dart

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final List<String> careInstructions;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.careInstructions,
    required this.category,
  });
}
