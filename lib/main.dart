import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() {
   // Rendre la barre de statut transparente
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: const Color.fromARGB(0, 255, 255, 255), // 🔥 Rend la barre de statut transparente
    statusBarIconBrightness: Brightness.light, // Icônes en blanc (utilise `dark` pour les avoir en noir)
    systemNavigationBarColor: const Color.fromARGB(255, 0, 0, 0), // Changer la couleur de la barre de navigation en bas
    systemNavigationBarIconBrightness: Brightness.light, // Icônes en blanc
  ));
  runApp(AlgrinovaApp());
}

class AlgrinovaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController = ScrollController();
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isVisible) {
          setState(() {
            _isVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _isVisible ? 155 : 0,
                child: _buildCurvedHeader(),
              ),
              SizedBox(height: 5),
              Expanded(
                child: ListView(
                  controller: _scrollController, // ✅ Ajout du contrôleur ici
                  padding: EdgeInsets.zero,
                  children: _buildPostList(),
                ),
              ),
            ],
          ),
          AnimatedPositioned(
  duration: Duration(milliseconds: 300),
  top: _isVisible ? 95 : -50, // 🔥 Maintenant elle disparaît aussi
  left: 20,
  right: 20,
  child: _buildSearchBar(),
),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCurvedHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            height: 170,
            decoration: BoxDecoration(
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
            children: [
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
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 300,
      height: 45,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 143, 48),
            Color.fromARGB(255, 0, 41, 14)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white),
        ),
      ),
    );
  }

  List<Widget> _buildPostList() {
    return [
      _buildPost(
        profileImage: "assets/images/pexels-dacapture-13734919.jpg",
        username: "Lora Lays",
        location: "Algerie, SBA",
        hashtag: "#Flower",
        caption: "New idea",
        image: "assets/images/pexels-pixabay-206876.jpg",
        likes: 22,
        comments: 22,
        shares: 22,
      ),
      _buildPost(
        profileImage: "assets/images/pexels-mlkbnl-10251392.jpg",
        username: "Lora Lays",
        location: "Algerie, SBA",
        hashtag: "#Nature",
        caption: "Amazing view!",
        image: "assets/images/pexels-david-bartus-43782-1166209.jpg",
        likes: 30,
        comments: 18,
        shares: 10,
      ),
      _buildPost(
        profileImage: "assets/images/pexels-mlkbnl-10251392.jpg",
        username: "Lora Lays",
        location: "Algerie, SBA",
        hashtag: "#Nature",
        caption: "Amazing view!",
        image: "assets/images/pexels-david-bartus-43782-1166209.jpg",
        likes: 30,
        comments: 18,
        shares: 10,
      ),
    ];
  }

  Widget _buildPost({
    required String profileImage,
    required String username,
    required String location,
    required String hashtag,
    required String caption,
    required String image,
    required int likes,
    required int comments,
    required int shares,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(profileImage),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(location, style: TextStyle(color: Color.fromRGBO(80, 80, 80, 1))),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: "$hashtag ",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: caption),
              ],
            ),
          ),
          SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(image, fit: BoxFit.cover),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: const Color.fromARGB(255, 255, 28, 55)),
                  SizedBox(width: 5),
                  Text(likes.toString()),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.mode_comment_rounded, color: Color.fromRGBO(80, 80, 80, 1)),
                  SizedBox(width: 5),
                  Text(comments.toString()),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.share, color: Color.fromRGBO(80, 80, 80, 1)),
                  SizedBox(width: 5),
                  Text(shares.toString()),
                ],
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed, // ✅ Assure que les labels restent visibles
    selectedItemColor: Color.fromARGB(255, 0, 143, 48),
    unselectedItemColor: Color.fromRGBO(80, 80, 80, 1),
    showSelectedLabels: true, // ✅ Garde le texte affiché
    showUnselectedLabels: true, // ✅ Garde aussi les labels gris
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.work), label: "Experts"),
      BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: "Chat"),
      BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Store"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
    ],
  );
}
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.3, size.height * 1.14, size.width * 0.6, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
