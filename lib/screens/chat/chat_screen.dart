import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:algrinova/screens/chat/message_screen.dart';
import 'package:algrinova/widgets/custom_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String? expertId;
  final String? expertEmail;
  bool _isVisible = true;

  ChatScreen({super.key, this.expertId, this.expertEmail});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatPartner {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String specialty;

  ChatPartner({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.specialty,
  });

  factory ChatPartner.fromExpert(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatPartner(
      id: doc.id,
      name: data['name'] ?? 'خبير',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      specialty: data['specialization'] ?? 'خبير',
    );
  }

  factory ChatPartner.fromUser(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatPartner(
      id: doc.id,
      name: data['name'] ?? 'مستخدم',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      specialty: '',
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Function resumeCallBack;
  final Function suspendingCallBack;

  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.suspendingCallBack,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        resumeCallBack();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        suspendingCallBack();
        break;
    }
  }
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();
  bool _isVisible = true;

  int getUnreadMessagesCount(
    AsyncSnapshot<QuerySnapshot> snapshot,
    String expertId,
    String currentUserId,
  ) {
    return snapshot.data!.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['senderId'] == expertId &&
          data['unreadBy'] != null &&
          (data['unreadBy'] as List).contains(currentUserId);
    }).length;
  }

   @override
  void initState() {
    super.initState();
    _updateUserStatus(true);
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
    _updateUserStatus(false);
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Disposed successfully')));
    });
  }

  // دالة محدثة مع معالجة الأخطاء
  Future<void> _updateUserStatus(bool isOnline) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'isOnline': isOnline,
              'lastSeen':
                  FieldValue.serverTimestamp(), // أفضل من DateTime.now()
            });
      }
    } catch (e) {
      debugPrint('Error updating user status: $e');
    }
  }
 @override
Widget build(BuildContext context) {
  return Scaffold(
    bottomNavigationBar: CustomBottomNavBar(
      context: context,
      currentIndex: 2,
    ),
    body: Stack(
      children: [
        /// Conteneur principal avec hauteur définie pour autoriser Expanded plus bas
        Positioned.fill(
          child: Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _isVisible ? 155 : 0,
                child: _buildCurvedHeader(),
              ),
              SizedBox(height: 5),
              /// Cette partie a maintenant une hauteur correcte
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: _buildOnlineUsersList(),
                    ),
                    Expanded(child: _buildChatList()),
                  ],
                ),
              ),
            ],
          ),
        ),
        /// Barre de recherche flottante
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          top: _isVisible ? 95 : -50,
          left: 20,
          right: 20,
          child: _buildSearchBar(),
        ),
      ],
    ),
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
        Positioned(
          top: 154,
          left: 0,
          right: 0,
          child: Container(
            height: 1.0,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 145, 145, 145),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 0.9,
                  offset: Offset(0, 1),
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
          hintText: "Rechercher",
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
  Widget _buildChatList() {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return Center(child: Text("Utilisateur non connecté"));
  }

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text("Aucune discussion pour le moment"));
      }

      final chats = snapshot.data!.docs;

      return ListView.separated( // <-- Utiliser ListView.separated si tu veux un séparateur
        itemCount: chats.length,
        separatorBuilder: (context, index) => Divider(
          height: 0, thickness: 0.5, color: Colors.grey.withOpacity(0.5),
        ),
        itemBuilder: (context, index) {
          final chatDoc = chats[index];
          final data = chatDoc.data() as Map<String, dynamic>;

          final participants = List<String>.from(data['participants']);
          final partnerId = participants.firstWhere((id) => id != currentUser.uid);

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(partnerId).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return SizedBox();
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              final name = userData['name'] ?? 'Utilisateur';
              final photoUrl = userData['photoUrl'] ?? 'assets/images/user1.png';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: photoUrl.startsWith('http')
                      ? NetworkImage(photoUrl)
                      : AssetImage('assets/images/user1.png') as ImageProvider,
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
                  data['lastMessage']! as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (data['unreadCount'] as int) > 0
                        ? const Color.fromARGB(255, 0, 143, 48)
                        : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTimestamp(data['lastMessageTime']),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if ((data['unreadCount'] as int) > 0)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 0, 0, 0),
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 4),
                          ),
                        ),
                        child: Text(
                          '${data['unreadCount']}',
                          style: const TextStyle(
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
                    builder: (context) => MessageScreen(
                      receiverUserId: partnerId,
                      receiverUserEmail: userData['email'] ?? '',
                      receiverUserphotoUrl: photoUrl,
                      receivername: name,
                    ),
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


  Widget _buildOnlineUsersList() {
    // مثال على بيانات وهمية للمستخدمين المتصلين
    final dummyOnlineUsers = [
      {'name': 'Alex', 'imageaUrl': 'assets/images/user1.png'},
      {'name': 'Sarah', 'photoUrl': 'assets/images/user1.png'},
      {'name': 'Mike', 'photoUrl': 'assets/images/user1.png'},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dummyOnlineUsers.length,
        itemBuilder: (context, index) {
          final user = dummyOnlineUsers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MessageScreen(
                                receiverUserId: 'dummy_id',
                                receiverUserEmail: 'dummy@email.com',
                                receiverUserphotoUrl:
                                    user['photoUrl'] ?? 'assets/images/user1.png',
                                receivername: user['name']!,
                              ),
                    ),
                  ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade400,
                        radius: 30,
                        backgroundImage: AssetImage(
                          user['photoUrl'] ?? 'assets/images/user1.png',
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 0, 143, 48),
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user['name']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'QuickSand',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
    path.lineTo(0, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

