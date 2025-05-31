import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algrinova/screens/store/details.dart';
import 'package:algrinova/screens/store/store_screen.dart';
import 'package:algrinova/screens/home/post_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    print(
      "current UID: ${FirebaseAuth.instance.currentUser!.uid}",
    ); // Debugging line to check current user UID
    if (user == null) {
      return const Center(child: Text('Vous devez être connecté.'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Profil non trouvé.')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String name = data['name'] ?? 'Inconnu';
        final String location = data['location'] ?? 'Inconnue';
        final String photoUrl = data['photoUrl'] ?? '';

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipPath(
                              clipper: BottomWaveClipper(),
                              child: Container(
                                height: 200,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/blur.png"),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 40),
                                        child: Text(
                                          'Algrinova',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Lobster',
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 40,
                                      left: 16,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 90,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          photoUrl != ""
                                              ? NetworkImage(photoUrl)
                                              : const AssetImage(
                                                    "assets/images/pexels-olly-3756616.jpg",
                                                  )
                                                  as ImageProvider,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 6,
                                    right: 6,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color:
                                            data['isOnline'] == true
                                                ? Color.fromARGB(
                                                  255,
                                                  0,
                                                  143,
                                                  48,
                                                )
                                                : Colors.grey,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 143, 48),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              size: 20,
                              color: Color.fromRGBO(80, 80, 80, 1),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(80, 80, 80, 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TabBar(
                          labelColor: Color.fromARGB(255, 0, 143, 48),
                          unselectedLabelColor: Color.fromRGBO(80, 80, 80, 1),
                          indicatorColor: Color.fromARGB(255, 0, 143, 48),
                          tabs: [
                            Tab(
                              child: Text(
                                'Articles',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Tab(
                              child: Text(
                                'Posts',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection('favorites')
                                        .doc(user.uid)
                                        .collection('likedItems')
                                        .where('type', isEqualTo: 'product')
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Il n y a pas d article favorise',
                                      ),
                                    );
                                  }

                                  final articles = snapshot.data!.docs;

                                  return GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: articles.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 4,
                                          mainAxisSpacing: 4,
                                        ),
                                    itemBuilder: (context, index) {
                                      final article =
                                          articles[index].data()
                                              as Map<String, dynamic>;

                                      return GestureDetector(
                                        onTap: () {
                                          final productModel = ProductModel(
                                            id: articles[index].id,
                                            name: article['name'] ?? '',
                                            description:
                                                article['description'] ?? '',
                                            price:
                                                (article['price'] ?? 0)
                                                    .toDouble(),
                                            imageUrls: [
                                              article['imageUrl'] ?? '',
                                            ],
                                            careInstructions: List<String>.from(
                                              article['careInstructions'] ?? [],
                                            ),
                                          );

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Details(
                                                    product: productModel,
                                                    careInstructions:
                                                        productModel
                                                            .careInstructions,
                                                  ),
                                            ),
                                          );
                                        },

                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            article['imageUrl'] ?? '',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

                              StreamBuilder<QuerySnapshot>(
                                stream:
                                    FirebaseFirestore.instance
                                        .collection('favorites')
                                        .doc(
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
                                        )
                                        .collection('likedPosts')
                                        .orderBy('timestamp', descending: true)
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "Aucune publication favorite",
                                      ),
                                    );
                                  }

                                  final favoritePosts =
                                      snapshot.data!.docs
                                          .map(
                                            (doc) =>
                                                doc.data()
                                                    as Map<String, dynamic>,
                                          )
                                          .toList();

                                  return GridView.builder(
                                    padding: const EdgeInsets.all(10),
                                    itemCount: favoritePosts.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          childAspectRatio: 0.8,
                                        ),
                                    itemBuilder: (context, index) {
                                      final postDoc = snapshot.data!.docs[index];
                                      final post = postDoc.data() as Map<String, dynamic>;
                                      final postId = postDoc.id;
                                      final currentUid = FirebaseAuth.instance.currentUser!.uid;

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => PostDetailScreen(
                                                    image:
                                                        post['imageUrl'] ?? '',
                                                    caption:
                                                        post['caption'] ?? '',
                                                    hashtag:
                                                        post['hashtag'] ?? '',
                                                    name: post['name'] ?? '',
                                                    location:
                                                        post['location'] ?? '',
                                                    likes:
                                                        (post['likes']
                                                                is List<String>)
                                                            ? post['likes']
                                                                as List<String>
                                                            : (post['likes']
                                                                is List)
                                                            ? List<String>.from(
                                                              post['likes'],
                                                            )
                                                            : <String>[],
                                                    comments:
                                                        post['comments'] ?? 0,
                                                    shares: post['shares'] ?? 0,
                                                    postId: postId,
                                                    postOwnerUid: currentUid,
                                                    ownerId: currentUid, // نفس الشيء
                                                  ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            post['imageUrl'] ?? '',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildGrid(List<String> items) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(items[index], fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
