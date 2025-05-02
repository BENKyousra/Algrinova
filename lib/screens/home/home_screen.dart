import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart'; // ✅ Ajoute cette ligne
import 'dart:io'; // ✅ Ajoute cette ligne pour utiliser `File`
import 'post_details_screen.dart';
import 'package:algrinova/widgets/custom_bottom_navbar.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController = ScrollController();
  bool _isVisible = true;
  TextEditingController _postController = TextEditingController();  // Contrôleur pour le champ de texte

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _userPosts = []; // Define _userPosts as a list of posts



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
  void dispose() {
    _scrollController.dispose();
    _postController.dispose();  // N'oublie pas de libérer les ressources du TextEditingController
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
final posts = [..._userPosts, ..._getPostData()];
final filteredList = posts.where((post) {
  return post['caption'].toLowerCase().contains(_searchQuery) ||
         post['username'].toLowerCase().contains(_searchQuery) ||
         post['hashtag'].toLowerCase().contains(_searchQuery);

}).toList();

  return GestureDetector(
    onTap: () {
    FocusScope.of(context).unfocus(); // Ferme le clavier et enlève le focus du champ
  },
  child: Scaffold(
    bottomNavigationBar: CustomBottomNavBar(
  context: context,
  currentIndex: 0, // par exemple 4 = profil
),
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
                controller: _scrollController,
                padding: EdgeInsets.zero,
                children: filteredList.map((post) {
                  return _buildPost(
                    profileImage: post['profileImage'],
                    username: post['username'],
                    location: post['location'],
                    hashtag: post['hashtag'],
                    caption: post['caption'],
                    image: post['image'],
                    likes: post['likes'],
                    comments: post['comments'],
                    shares: post['shares'],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          top: _isVisible ? 95 : -50,
          left: 20,
          right: 20,
          child: _buildSearchBar(),
        ),
      ],
    ),

    // ✅ Bouton flottant stylisé en dégradé vert
    floatingActionButton: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 143, 48),
            Color.fromARGB(255, 0, 41, 14),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: IconButton(
        icon: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showPostDialog(context),
      ),
    ),

    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // ✅ En bas à droite
  ),
  );
}

TextEditingController _hashtagController = TextEditingController();

void _showPostDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Titre
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Créer un post",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 143, 48),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // ✅ Champ texte
                  TextField(
                    controller: _postController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      hintText: "Quoi de neuf ?",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _hashtagController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF5F5F5),
                      hintText: "Entrez un hashtag...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (text) {
                      // Ajoute un # automatiquement lorsque l'utilisateur tape un mot
                      if (text.isNotEmpty && !text.startsWith('#')) {
                        _hashtagController.text = '#$text';
                        _hashtagController.selection = TextSelection.collapsed(offset: _hashtagController.text.length);
                      }
                    },
                  ), 
                  SizedBox(height: 10),
                  // ✅ Image sélectionnée (si elle existe)
                  _pickedImage != null
                      ? Column(
                          children: [
                            Image.file(
                              File(_pickedImage!.path),
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 10),
                          ],
                        )
                      : SizedBox(),

                  // ✅ Bouton pour choisir une image
                  ElevatedButton.icon(
                    onPressed: () async {
                      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _pickedImage = image;
                        });
                      }
                    },
                    icon: Icon(Icons.photo_library,color: const Color.fromARGB(255, 255, 255, 255)),
                    label: Text("Ajouter une image",style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255),fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // ✅ Boutons en bas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _postController.clear();
                          _pickedImage = null;
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Annuler",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          backgroundColor: Color.fromARGB(255, 0, 143, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
  if (_postController.text.isNotEmpty || _pickedImage != null) {
    Navigator.pop(context); // ferme le dialog AVANT le setState
    setState(() {
      _userPosts.insert(0, {
        'profileImage': 'assets/images/ton_image.jpg',
        'username': 'Moi',
        'location': 'Algérie',
        'hashtag': _hashtagController.text.isNotEmpty ? _hashtagController.text : '',
        'caption': _postController.text,
        'image': _pickedImage!.path,
        'likes': 0,
        'comments': 0,
        'shares': 0,
      });
      _postController.clear();
      _pickedImage = null;
    });
  }
},

                        child: Text(
                          "Publier",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
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
        // Ligne grise avec ombre juste après la courbe
        Positioned(
          top: 154, // Positionne la ligne juste en dessous de la courbe
          left: 0,
          right: 0,
          child: Container(
            height: 1.0, // La hauteur de la ligne
            margin: EdgeInsets.only(
              top: 0,
            ), // Marge de 5px pour l'espace entre la courbe et la ligne
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                255,
                145,
                145,
                145,
              ), // Couleur de la ligne
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Couleur de l'ombre
                  spreadRadius: 1, // Étend l'ombre
                  blurRadius: 0.9, // Intensité de l'ombre
                  offset: Offset(
                    0,
                    1,
                  ), // Position de l'ombre (ici, vers le bas)
                ),
              ],
            ),
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
          Color.fromARGB(255, 0, 41, 14),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Rechercher...",
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
        icon: Icon(Icons.search, color: Colors.white),
      ),
      style: TextStyle(color: Colors.white),
    ),
  );
}

  List<Map<String, dynamic>> _getPostData() {
    return [
      {
        'profileImage': "assets/images/pexels-dacapture-13734919.jpg",
        'username': "Lora Lays",
        'location': "Algerie, SBA",
        'hashtag': "#Flower",
        'caption': "New idea",
        'image': "assets/images/pexels-pixabay-206876.jpg",
        'likes': 22,
        'comments': 22,
        'shares': 22,
      },
      {
        'profileImage': "assets/images/pexels-mlkbnl-10251392.jpg",
        'username': "Lora Lays",
        'location': "Algerie, SBA",
        'hashtag': "#Nature",
        'caption': "Amazing view!",
        'image': "assets/images/pexels-david-bartus-43782-1166209.jpg",
        'likes': 30,
        'comments': 18,
        'shares': 10,
      },
      {
        'profileImage': "assets/images/pexels-mlkbnl-10251392.jpg",
        'username': "Lora Lays",
        'location': "Algerie, SBA",
        'hashtag': "#Nature",
        'caption': "Amazing view!",
        'image': "assets/images/pexels-david-bartus-43782-1166209.jpg",
        'likes': 30,
        'comments': 18,
        'shares': 10,
      },
    ];
  }

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
  return StatefulBuilder(
    builder: (context, setState) {
      bool isLiked = false;
      int likeCount = likes;
      int commentCount = comments;
      int shareCount = shares;

      return GestureDetector(
        onTap: () {
          // Naviguer vers la page de détails du post
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(
                profileImage: profileImage,
                username: username,
                location: location,
                hashtag: hashtag,
                caption: caption,
                image: image,
                likes: likeCount,
                comments: commentCount,
                shares: shareCount,
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundImage: AssetImage(profileImage)),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                      Text(location, style: TextStyle(color: Color.fromARGB(255, 0, 143, 48),fontWeight: FontWeight.bold,fontSize: 12)),
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
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: caption),
                  ],
                ),
              ),
              SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: image.startsWith('assets/')
      ? Image.asset(image, fit: BoxFit.cover)
      : Image.file(File(image), fit: BoxFit.cover),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                        likeCount += isLiked ? 1 : -1;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          // ignore: dead_code
                          color: isLiked ? const Color.fromARGB(255, 255, 47, 92) : Color.fromRGBO(80, 80, 80, 1),
                        ),
                        SizedBox(width: 5),
                        Text(likeCount.toString()),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        commentCount += 1;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Fonction commentaire à implémenter")),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.mode_comment_rounded, color: Color.fromRGBO(80, 80, 80, 1)),
                        SizedBox(width: 5),
                        Text(commentCount.toString()),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        shareCount += 1;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lien copié ou partagé !")),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Color.fromRGBO(80, 80, 80, 1)),
                        SizedBox(width: 5),
                        Text(shareCount.toString()),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
            ],
          ),
        ),
      );
    },
  );
}


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

    path.lineTo(0, size.height * 0.4); // Retour à la base de la courbe
    path.lineTo(
      size.width,
      size.height * 0.4,
    ); // Ajouter une ligne horizontale en bas de la courbe
    path.lineTo(size.width, 0); // Fermer le chemin

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
