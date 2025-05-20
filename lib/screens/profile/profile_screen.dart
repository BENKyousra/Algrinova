import 'package:flutter/material.dart';
import 'package:algrinova/widgets/custom_bottom_navbar.dart';
import 'package:algrinova/screens/home/post_details_screen.dart';
import 'package:algrinova/screens/profile/favorites_screen.dart';
import 'package:algrinova/screens/profile/settings_screen.dart';
import 'package:algrinova/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userService = UserService();
  late String uid;
  late Future<DocumentSnapshot> _userFuture;

  final List<String> userPosts = [
    'assets/images/pexels-nati-87264186-21939593.jpg',
    'assets/images/pexels-merictuna-30487734.jpg',
    'assets/images/pexels-alice1-30518938.jpg',
    'assets/images/pexels-nati-87264186-21939593.jpg',
    'assets/images/vecteezy_young-bright-green-zucchini-sprout-in-a-peat-pot_48836315.jpg',
    'assets/images/pexels-merictuna-30132057.jpg',
  ];

  @override
  void initState() {
    super.initState();

  final user = FirebaseAuth.instance.currentUser;
  print("UID utilisateur : ${user?.uid}");

  
    if (user == null) {
      // Personne n'est connecté → redirige vers login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      // L'utilisateur est connecté, obtenir son uid
      uid = user.uid;
      _userFuture = userService.getUserProfile(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: 4,
      ),
      body: 
      
      FutureBuilder<DocumentSnapshot>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}

if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}

if (snapshot.hasError) {
  print("Erreur snapshot : ${snapshot.error}");
  return const Center(child: Text('Erreur de chargement du profil.'));
}

if (!snapshot.hasData) {
  print("Aucune donnée reçue !");
  return const Center(child: Text('Erreur : aucune donnée.'));
}

final userData = snapshot.data;

if (userData == null || !userData.exists) {
  print("Le document n'existe pas !");
  return const Center(child: Text('Profil introuvable.'));
}


          String name = 'Nom inconnu';
          String location = 'Localisation inconnue';
          String photoUrl = '';

          if (snapshot.hasData) {
            final userData = snapshot.data!;
            name = userData['name'] ?? 'Nom inconnu';
            location = userData['location'] ?? 'Localisation inconnue';
            photoUrl = userData['photoUrl'] ?? '';  // Utilise une valeur par défaut
          } else {
            print('Aucune donnée utilisateur récupérée.');
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                                  Positioned(
                                    top: 40,
                                    left: 16,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FavoritesScreen(),
                                          ),
                                        );
                                      },
                                      child: const Icon(Icons.favorite_rounded, color: Colors.white),
                                    ),
                                  ),
                                  Positioned(
                                    top: 40,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SettingsScreen(),
                                          ),
                                        );
                                      },
                                      child: const Icon(Icons.settings, color: Colors.white),
                                    ),
                                  ),
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
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 90,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: photoUrl != ""
                                    ? NetworkImage(photoUrl)
                                    : const AssetImage("assets/images/pexels-olly-3756616.jpg") as ImageProvider,
                              ),
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_pin, size: 20, color: Color.fromRGBO(80, 80, 80, 1)),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(fontSize: 16, color: Color.fromRGBO(80, 80, 80, 1)),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(color: Colors.grey, thickness: 0.8),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: userPosts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 3,
                            mainAxisSpacing: 3,
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailScreen(
                                      profileImage: photoUrl,
                                      username: name,
                                      location: location,
                                      hashtag: '#Plante',
                                      caption: 'Post ${index + 1}',
                                      image: userPosts[index],
                                      likes: 100,
                                      comments: 5,
                                      shares: 2,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  userPosts[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
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
      size.width / 2, size.height,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
