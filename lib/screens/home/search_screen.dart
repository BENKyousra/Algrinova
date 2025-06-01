import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algrinova/screens/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algrinova/screens/home/post_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<List<Map<String, dynamic>>> _searchPosts(String query) async {
    if (query.isEmpty) return [];
    final snapshot =
        await _firestore
            .collection('allPosts')
            .where('caption', isGreaterThanOrEqualTo: query)
            .where('caption', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> _searchHashtags(String query) async {
    if (query.isEmpty) return [];
    // في هذه الحالة نفترض أن لدينا حقل "hashtags" نوعه array في كل مستند
    final snapshot =
        await _firestore
            .collection('allPosts')
            .where('hashtag', isGreaterThanOrEqualTo: query)
            .where('hashtag', isLessThanOrEqualTo: '$query\uf8ff')
            .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> _searchUsers(String query) async {
    // Appel Firestore pour récupérer les users correspondant à la recherche
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff')
            .get();

    // Transforme les docs en List<Map<String, dynamic>>
    List<Map<String, dynamic>> results =
        snapshot.docs.map((doc) {
          return {
            'uid': doc.id,
            'name': doc['name'],
            'photoUrl': doc['photoUrl'] ?? '',
          };
        }).toList();

    return results;
  }

  // الواجهات الفرعية لكل تبويب
  Widget _emptyState(String message) => Center(child: Text(message));

  Widget _buildUsersTab() {
    if (_searchQuery.isEmpty) {
      return _emptyState("Start typing to search users");
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchUsers(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyState("No users found.");
        }
        final users = snapshot.data!;
        print("Search results:");
        for (var u in users) {
          print("${u['name']} - ${u['uid']}");
        }
        final currentUid = FirebaseAuth.instance.currentUser!.uid;
        final filteredUsers =
            users.where((u) => u['uid'] != currentUid).toList();
        List<Map<String, dynamic>> searchResults = filteredUsers;
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: searchResults.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final user = searchResults[index];
            final photoUrl =
                user['photoUrl'] ??
                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(photoUrl),
                radius: 24,
              ),
              title: Text(user['name'] ?? ''),
              onTap: () {
                final clickedUid = user['uid'];
                print('User cliqué : ${user['name']} / uid: $clickedUid');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(uid: clickedUid), // 🔥 ICI
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPostsTab() {
    if (_searchQuery.isEmpty) {
      return _emptyState("Start typing to search posts");
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchPosts(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyState("No posts found.");
        }
        final posts = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: posts.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final post = posts[index];
            final imageUrl =
                post['imageUrl'] ??
                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
            final caption = post['caption'] ?? '';
            final hashtag = post['hashtag'] ?? [];
            final name = post['name'] ?? '';
            final location = post['location'] ?? '';
            final likes = post['likes'] ?? [];
            final comments = post['comments'] ?? [];
            final shares = post['shares'] ?? [];
            final postId = post['postId'] ?? '';
            final userId = post['userId'] ?? '';

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(caption),
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
                          likes: List<String>.from(likes),
                          comments: comments,
                          shares: shares,
                          postId: postId,
                          postOwnerUid: userId,
                          ownerId: userId,
                        ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHashtagsTab() {
    if (_searchQuery.isEmpty) {
      return _emptyState("Start typing to search hashtags");
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchHashtags(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyState("No hashtags found.");
        }
        final hashtag = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: hashtag.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final hashtagDoc = hashtag[index];
            final caption = hashtagDoc['caption'] ?? '';
            final tagsList = hashtagDoc['hashtag'] ?? [];
            final imageUrl = hashtagDoc['imageUrl'] ??
                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
            final name = hashtagDoc['name'] ?? '';
            final location = hashtagDoc['location'] ?? '';
            final likes = hashtagDoc['likes'] ?? [];
            final comments = hashtagDoc['comments'] ?? [];
            final shares = hashtagDoc['shares'] ?? [];
            final postId = hashtagDoc['postId'] ?? '';
            final userId = hashtagDoc['userId'] ?? '';

            return ListTile(
              title: Text(tagsList is List ? tagsList.join(', ') : tagsList.toString()),
              subtitle: Text(caption),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                      image: imageUrl,
                      caption: caption,
                      hashtag: tagsList is List && tagsList.isNotEmpty ? tagsList.first.toString() : '',
                      name: name,
                      location: location,
                      likes: List<String>.from(likes),
                      comments: comments,
                      shares: shares,
                      postId: postId,
                      postOwnerUid: userId,
                      ownerId: userId,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            //ضيي
            SizedBox(
              height: 220,
              child: Stack(
                // القسم العلوي: الخلفية + خانة البحث + التبويبات
                children: [
                  _buildCurvedHeader(), // خلفية منحني
                  // خانة البحث الجديدة
                  Positioned(
                    top: 90.5,
                    left: 0,
                    right: 0,
                    child: CustomSearchBar(
                      onChanged:
                          (value) =>
                              setState(() => _searchQuery = value.trim()),
                      onClear: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _searchQuery = "");
                      },
                    ),
                  ),
                  // TabBar
                  Positioned(
                    top: 160,
                    left: 0,
                    right: 0,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.black54,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 2,
                          color: const Color.fromARGB(255, 18, 61, 18),
                        ), // خط بنفسجي بسُمك 3
                        insets: EdgeInsets.symmetric(
                          horizontal: 50,
                        ), // مسافة من الجانبين
                      ),
                      tabs: const [
                        Tab(text: "Users"),
                        Tab(text: "Posts"),
                        Tab(text: "Hashtags"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // محتوى التبويبات
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUsersTab(),
                  _buildPostsTab(),
                  _buildHashtagsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurvedHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            height: 155,
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
        Positioned(
          top: 154,
          left: 0,
          right: 0,
          child: Container(
            height: 1.0,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 200, 200, 200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//add
class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hint;
  const CustomSearchBar({
    super.key,
    required this.onChanged,
    this.onClear,
    this.hint = 'Rechercher...',
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 143, 48),
            Color.fromARGB(255, 0, 41, 14),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
          if (onClear != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
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
