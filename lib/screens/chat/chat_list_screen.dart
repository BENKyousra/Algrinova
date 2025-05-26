import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algrinova/screens/chat/message_screen.dart'; // Assure-toi de mettre le bon chemin

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isVisible = true; // pour ton header animé
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Animation header : cacher header au scroll down
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isVisible) setState(() => _isVisible = false);
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isVisible) setState(() => _isVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 1) {
      return "${difference.inDays}j";
    } else if (difference.inHours >= 1) {
      return "${difference.inHours}h";
    } else if (difference.inMinutes >= 1) {
      return "${difference.inMinutes}m";
    } else {
      return "maintenant";
    }
  }

  Widget _buildCurvedHeader() {
    // Remplace par ton widget header personnalisé
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      height: 155,
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(
        'Discussions',
        style: TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'QuickSand',
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey[600]),
          hintText: 'Rechercher une discussion',
          border: InputBorder.none,
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val.toLowerCase();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Discussions')),
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  top: _isVisible ? 95 : -50,
                  left: 20,
                  right: 20,
                  child: _buildSearchBar(),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .where('participants', arrayContains: currentUser!.uid)
                        .orderBy('lastMessageTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("Aucune discussion"));
                      }

                      final chats = snapshot.data!.docs;

                      // Filtrer les chats selon la recherche sur le nom du partenaire
                      final filteredChats = chats.where((doc) {
                        final data = doc.data()! as Map<String, dynamic>;
                        final participants = List<String>.from(data['participants']);
                        final partnerId = participants.firstWhere((id) => id != currentUser!.uid);

                        // On récupère le nom partenaire via un champ dans messages ou autre
                        // Si tu n'as pas le nom dans messages, faudra récupérer dans users (FutureBuilder)
                        // Ici, on fait simple : on affiche tous, recherche sur lastMessage ou autre plus tard
                        return true;
                      }).toList();

                      return ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.only(top: 10),
                        itemCount: filteredChats.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 0,
                          thickness: 0.5,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        itemBuilder: (context, index) {
                          final chatDoc = filteredChats[index];
                          final data = chatDoc.data()! as Map<String, dynamic>;

                          final participants = List<String>.from(data['participants']);
                          final partnerId =
                              participants.firstWhere((id) => id != currentUser!.uid);

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(partnerId)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) return SizedBox();

                              final userData =
                                  userSnapshot.data!.data() as Map<String, dynamic>;

                              final name = userData['name'] ?? 'Utilisateur';
                              final photoUrl = userData['photoUrl'] ?? '';

                              // Filtrer par nom avec recherche
                              if (_searchQuery.isNotEmpty &&
                                  !name.toLowerCase().contains(_searchQuery)) {
                                return SizedBox();
                              }

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: photoUrl.startsWith('http')
                                      ? NetworkImage(photoUrl)
                                      : AssetImage('assets/images/user1.png')
                                          as ImageProvider,
                                  radius: 28,
                                ),
                                title: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'QuickSand',
                                  ),
                                ),
                                subtitle: Text(
                                  data['lastMessage'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: (data['unreadCount'] ?? 0) > 0
                                        ? Color.fromARGB(255, 0, 143, 48)
                                        : Colors.grey,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTimestamp(data['lastMessageTime']),
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    if ((data['unreadCount'] ?? 0) > 0)
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.black, width: 4),
                                        ),
                                        child: Text(
                                          '${data['unreadCount']}',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MessageScreen(
                                      receiverUserId: partnerId,
                                      receivername: name,
                                      receiverUserphotoUrl: photoUrl,
                                      receiverUserEmail: userData['email'] ?? '',
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
