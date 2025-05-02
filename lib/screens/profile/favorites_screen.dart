import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final List<String> likedPosts = [
    'assets/images/pexels-nati-87264186-21939593.jpg',
    'assets/images/pexels-merictuna-30487734.jpg',
    'assets/images/pexels-nati-87264186-21939593.jpg',
    'assets/images/pexels-merictuna-30487734.jpg',
  ];

  final List<String> likedStoreItems = [
    'assets/images/pexels-alice1-30518938.jpg',
    'assets/images/pexels-merictuna-30132057.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoris'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title: 'Posts aimés'),
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: likedPosts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  likedPosts[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            SectionTitle(title: 'Articles de Store aimés'),
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: likedStoreItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  likedStoreItems[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}
