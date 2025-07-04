import 'package:algrinova/widgets/post_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart'; // ✅ Ajoute cette ligne
import 'dart:io'; // ✅ Ajoute cette ligne pour utiliser `File`
import 'post_details_screen.dart';
import 'package:algrinova/widgets/custom_bottom_navbar.dart';
import 'package:algrinova/services/post_service.dart';
import 'package:algrinova/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:algrinova/screens/home/search_screen.dart';
import 'package:algrinova/services/favorites_service.dart';

final PostService postService = PostService();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService postService = PostService();
  final UserService userService = UserService();
  bool isLoadingPostData = true;
  final FavoritesService _favoritesService = FavoritesService();

  final bool _isLiked = false;

  final ScrollController _scrollController = ScrollController();
  bool _isVisible = true;
  final TextEditingController _postController =
      TextEditingController(); // Contrôleur pour le champ de texte
  XFile? _pickedImage;

  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';
  final List<Map<String, dynamic>> _userPosts =
      []; // Define _userPosts as a list of posts
  final List<Map<String, dynamic>> _posts =
      []; // <-- Add this line to define _posts

  @override
  void initState() {
    super.initState();
    _syncGlobalPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible) {
          if (!mounted) return;
          setState(() {
            _isVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isVisible) {
           if (!mounted) return;
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
    _postController.dispose();
    super.dispose();
  }

  void _syncGlobalPosts() async {
    await PostService().syncAllPostsToGlobalCollection();
  }

  String getPostId(dynamic postIdField) {
    if (postIdField == null) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
    if (postIdField is DocumentReference) {
      return postIdField.id;
    }
    if (postIdField is String) {
      return postIdField;
    }
    // si tu veux, tu peux gérer un autre cas ou throw une erreur
    throw Exception('Type inattendu pour postId : ${postIdField.runtimeType}');
  }

  bool _isPicking = false;

  Future<void> pickImage() async {
    if (_isPicking) return; // Prevent multiple pickers
    _isPicking = true;
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      // handle picked image
    } finally {
      _isPicking = false;
    }
  }

  Future<void> _refreshPosts() async {
     if (!mounted) return;
    setState(() {}); // Force le rebuild, relance le StreamBuilder
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(
          context,
        ).unfocus(); // Ferme le clavier et enlève le focus du champ
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
                  height:
                      _isVisible
                          ? 155
                          : 0, // Ajuste la hauteur en fonction de la visibilité
                  child: _buildCurvedHeader(),
                ),

                // Espace entre le header et les posts
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: postService.getAllPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }

                      final posts = snapshot.data ?? [];

                      if (posts.isEmpty) {
                        return Center(child: Text('Aucun post trouvé.'));
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshPosts,
                        child: ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];

                            // Vérifie si le post a un 'postId' valide
                            if (post['postId'] == null ||
                                post['postId'] is! String) {
                              print(
                                "Post sans postId valide, génération d'un ID temporaire",
                              );
                              post['postId'] =
                                  DateTime.now().millisecondsSinceEpoch
                                      .toString();
                            }

                            // Récupère l'ID du post
                            String postId = getPostId(post['postId']);

                            return _buildPost(
                              photoUrl:
                                  post['photoUrl'] ??
                                  'assets/images/default.jpg',
                              name: post['name'] ?? 'Utilisateur',
                              location: post['location'] ?? 'Algérie',
                              hashtag: post['hashtag'] ?? '',
                              caption: post['caption'] ?? '',
                              imageUrl: post['imageUrl'] ?? '',
                              likes:
                                  (post['likes'] != null &&
                                          post['likes'] is List)
                                      ? post['likes'] as List
                                      : <dynamic>[],
                              currentUserId:
                                  FirebaseAuth.instance.currentUser!.uid,
                              postId: getPostId(post['postId']),
                              userId: post['userId'],
                              comments: post['comments'] ?? 0,
                              shares: post['shares'] ?? 0,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: _isVisible ? 95 : -50,
              left: 20,
              right: 20,
              child: _buildSearchBar(context),
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

        floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat, // ✅ En bas à droite
      ),
    );
  }

  final TextEditingController _hashtagController = TextEditingController();

  void _showPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> publishPost() async {
              if (_postController.text.isEmpty && _pickedImage == null) return;

              setStateDialog(() => isLoading = true);

              try {
                String? imageUrl;

                // Upload de l'image sur Cloudinary si sélectionnée
                if (_pickedImage != null) {
                  imageUrl = await uploadImageToCloudinary(
                    File(_pickedImage!.path),
                  );
                  if (imageUrl == null) {
                    throw Exception("Échec de l'upload de l'image");
                  }
                }

                // Appel à ta méthode publishPost (à adapter si besoin)
                final uid = FirebaseAuth.instance.currentUser!.uid;
                final userDoc =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get();
                final userData = userDoc.data() ?? {};
                if (!mounted) return;
                setState(() {
                  _userPosts.insert(0, {
                    'photoUrl':
                        userData['photoUrl'] ??
                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                    'name': userData['name'] ?? 'Nom inconnu',
                    'location': userData['location'] ?? 'Inconnu',
                    'hashtag': _hashtagController.text,
                    'caption': _postController.text,
                    'imageUrl': imageUrl ?? '',
                    'likes': [],
                    'comments': 0,
                    'shares': 0,
                    'userId': uid,
                    'postId': DateTime.now().millisecondsSinceEpoch.toString(),
                    'timestamp':
                        Timestamp.now(), // Ajoute le timestamp localement
                  });
                });
                await postService.publishPost(
                  caption: _postController.text,
                  hashtag: _hashtagController.text,
                  imageUrl: imageUrl,
                );

                // Nettoyage des champs
                _postController.clear();
                _hashtagController.clear();
                _pickedImage = null;

                Navigator.of(context).pop(); // Ferme le dialog
                setStateDialog(() => isLoading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Post publié avec succès !")),
                );
              } catch (e) {
                setStateDialog(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur lors de la publication : $e")),
                );
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre et fermeture
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

                    // Champ texte
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

                    // Champ hashtag
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
                        if (text.isNotEmpty && !text.startsWith('#')) {
                          _hashtagController.text = '#$text';
                          _hashtagController
                              .selection = TextSelection.collapsed(
                            offset: _hashtagController.text.length,
                          );
                        }
                      },
                    ),
                    SizedBox(height: 10),

                    // Image sélectionnée
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

                    // Bouton choisir image
                    ElevatedButton.icon(
                      onPressed: () async {
                        final XFile? image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setStateDialog(() {
                            _pickedImage = image;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.photo_library,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      label: Text(
                        "Ajouter une image",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
                        foregroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Boutons bas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _postController.clear();
                            _hashtagController.clear();
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            backgroundColor: Color.fromARGB(255, 0, 143, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading ? null : publishPost,
                          child:
                              isLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
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

  Widget _buildPost({
    required String photoUrl,
    required String name,
    required String location,
    required String hashtag,
    required String caption,
    required String imageUrl,
    required List likes,
    required String currentUserId,
    required String postId,
    required String userId,
    required int comments,
    required int shares,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        final FavoritesService favoritesService = FavoritesService();
        bool isLiked = likes.contains(currentUserId);
        int likeCount = likes.length;
        int commentCount = comments;
        int shareCount = shares;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PostDetailScreen(
                      image: imageUrl,
                      caption: caption,
                      hashtag: hashtag,
                      name: name,
                      location: location,
                      likes: likes.cast<String>(),
                      comments: commentCount,
                      shares: shareCount,
                      postId: postId,
                      postOwnerUid: userId,
                      ownerId: userId,
                    ),
              ),
            );
            if (!mounted) return;
            setState(() {});
          },
          child: Container(
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 0,
              // Décale le premier post pour qu'il colle au header
            ),
            decoration: BoxDecoration(
              // Fond blanc pour la carte du post
              borderRadius: BorderRadius.circular(16), // Coins arrondis
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                          );
                        }
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final photoUrl = snapshot.data!['photoUrl'];
                          return CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(photoUrl),
                          );
                        }
                        return CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(
                            'assets/images/default.png',
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          location,
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 143, 48),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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
                  child:
                      imageUrl != ''
                          ? Image.network(imageUrl)
                          : SizedBox(), // ou une image placeholder
                ),
                SizedBox(height: 5),
                PostActionBar(
                  ownerId: userId,
                  postId: postId,
                  initialLikes: likes.length,
                  comments: comments,
                  shares: shares,
                  likedBy: Set<String>.from(
                    likes.cast<String>(),
                  ), // pour être sûr que c'est un Set<String>
                  onCommentTap: () {
                    // Navigation vers la page des commentaires ou autre action
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PostDetailScreen(
                              image: imageUrl,
                              caption: caption,
                              hashtag: hashtag,
                              name: name,
                              location: location,
                              likes: likes.cast<String>(),
                              comments: comments,
                              shares: shares,
                              postId: postId,
                              postOwnerUid: userId,
                              ownerId: userId,
                            ),
                      ),
                    );
                  },
                  onLikeChanged: (bool isLikedNow, int newCount) {
                     if (!mounted) return;
    setState(() {
      isLiked = isLikedNow;
      likeCount = newCount;
    });
  },
                ),

                Divider(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen()),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Rechercher...",
              style: TextStyle(color: Colors.white70, fontFamily: 'Quicksand'),
            ),
          ],
        ),
      ),
    );
  }
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
              child: Image.asset('assets/icon.png', width: 28, height: 28),
            ),
            SizedBox(width: 5),
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
                offset: Offset(0, 1), // Position de l'ombre (ici, vers le bas)
              ),
            ],
          ),
        ),
      ),
    ],
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
