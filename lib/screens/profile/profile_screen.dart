import 'package:flutter/material.dart';
import 'package:algrinova/widgets/custom_bottom_navbar.dart';
import 'package:algrinova/screens/home/post_details_screen.dart';
import 'package:algrinova/screens/profile/favorites_screen.dart'; // Assure-toi que l'import est bon
import 'package:algrinova/screens/profile/settings_screen.dart';


class ProfileScreen extends StatelessWidget {
  final List<String> userPosts = [
    'assets/images/pexels-nati-87264186-21939593.jpg',
    'assets/images/pexels-merictuna-30487734.jpg',
    'assets/images/pexels-alice1-30518938.jpg',
    'assets/images/pexels-nati-87264186-21939593.jpg',
    'assets/images/vecteezy_young-bright-green-zucchini-sprout-in-a-peat-pot_48836315.jpg',
    'assets/images/pexels-merictuna-30132057.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: 4,
      ),
      body: LayoutBuilder(
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
          builder: (context) => FavoritesScreen(), // on va la créer juste après
        ),
      );
    },
    child: Icon(Icons.favorite_rounded, color: Colors.white),
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
    child: Icon(Icons.settings, color: Colors.white),
  ),
),

                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
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
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage("assets/images/pexels-olly-3756616.jpg"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Louis Squelette',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 143, 48),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_pin, size: 20, color: Color.fromRGBO(80, 80, 80, 1)),
                      SizedBox(width: 4),
                      Text(
                        'Algerie, SBA',
                        style: TextStyle(fontSize: 16, color: Color.fromRGBO(80, 80, 80, 1)),
                      ),
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.8,
                    ),
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
                                  profileImage: 'assets/images/pexels-olly-3756616.jpg',
                                  username: 'Louis Squelette',
                                  location: 'Algerie, SBA',
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
      ),
    );
  }
}

// Courbe du header
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
