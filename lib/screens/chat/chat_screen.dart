import 'package:algrinova/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:algrinova/screens/chat/message_screen.dart';
import 'package:algrinova/widgets/custom_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String? expertId;
  final String? expertEmail;

  const ChatScreen({super.key, this.expertId, this.expertEmail});

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
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible) {
          setState(() {
            _isVisible = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
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
    _scrollController.dispose(); // Très important si tu l'as initialisé
    super.dispose();
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
    final currentUserId = _auth.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('chatRooms')
              .where('participants', arrayContains: currentUserId)
              .orderBy('lastMessageTime', descending: true)
              .snapshots(),
      builder: (context, chatRoomsSnapshot) {
        if (chatRoomsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatRoomsSnapshot.hasError) {
          return Center(child: Text('Error: ${chatRoomsSnapshot.error}'));
        }

        if (!chatRoomsSnapshot.hasData ||
            chatRoomsSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No conversations yet'));
        }

        return FutureBuilder<List<ChatPartner?>>(
          future: Future.wait(
            chatRoomsSnapshot.data!.docs.map((chatRoom) async {
              final participants =
                  (chatRoom['participants'] as List<dynamic>).cast<String>();
              final partnerId = participants.firstWhere(
                (id) => id != currentUserId,
              );

              final partner = await _getChatPartnerDetails(partnerId);

              // ✅ Vérifie que le widget est toujours monté avant de retourner quoi que ce soit
              if (!mounted) return null;

              return partner;
            }).toList(),
          ),

          builder: (context, partnersSnapshot) {
            if (partnersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredPartners =
                partnersSnapshot.data!
                    .where(
                      (partner) =>
                          partner != null &&
                          (partner.name.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                              _searchQuery.isEmpty),
                    )
                    .toList();

            if (filteredPartners.isEmpty) {
              return const Center(child: Text('No search results'));
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredPartners.length,

              itemBuilder: (context, index) {
                final chatService = ChatService();
                final partner = filteredPartners[index]!;
                final chatRoom = chatRoomsSnapshot.data!.docs[index];
                final lastMessage =
                    chatRoom['lastMessage'] as String? ?? 'No messages yet';
                final unreadBy = List<String>.from(chatRoom['unreadBy'] ?? []);
                final userUnreadCount =
                    unreadBy.where((id) => id == currentUserId).length;

                return Dismissible(
                  key: Key(chatRoom.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,

                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await chatService.deleteChat(
                      context: context,
                      chatRoomId: chatRoom.id,
                      partnerName: partner.name,
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage:
                          partner.photoUrl.isNotEmpty
                              ? NetworkImage(partner.photoUrl)
                              : const AssetImage(
                                    'assets/images/default_profile.png',
                                  )
                                  as ImageProvider,
                    ),
                    title: Text(
                      partner.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'QuickSand',
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      style: TextStyle(
                        color:
                            userUnreadCount > 0
                                ? const Color.fromARGB(255, 0, 143, 48)
                                : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatLastMessageTime(
                            chatRoom['lastMessageTime'] as Timestamp?,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (userUnreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 0, 0, 0),
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Text(
                              '$userUnreadCount',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MessageScreen(
                                  receiverUserId: partner.id,
                                  receiverUserEmail: partner.email,
                                  receiverUserphotoUrl: partner.photoUrl,
                                  receivername: partner.name,
                                ),
                          ),
                        ),
                  ),
                );
              },
              separatorBuilder:
                  (context, index) => Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Colors.grey.withOpacity(0.5),
                  ),
            );
          },
        );
      },
    );
  }

  Widget _buildOnlineUsersList() {
    return SizedBox(
      height: 90,
      child: StreamBuilder<List<ChatPartner>>(
        stream: _getOnlineChatPartners(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No online users'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final partner = snapshot.data![index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MessageScreen(
                                receiverUserId: partner.id,
                                receiverUserEmail: partner.email,
                                receiverUserphotoUrl: partner.photoUrl,
                                receivername: partner.name,
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
                            backgroundImage:
                                partner.photoUrl.isNotEmpty
                                    ? NetworkImage(partner.photoUrl)
                                    : const AssetImage(
                                          'assets/images/default_profile.png',
                                        )
                                        as ImageProvider,
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        partner.name,
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
          );
        },
      ),
    );
  }

  Map<String, String> getUserBasicInfo(Map<String, dynamic> userData) {
    final username =
        userData['username'] as String? ??
        userData['name'] as String? ??
        userData['displayName'] as String? ??
        (userData['email'] as String?)?.split('@').first ??
        'Unknown';

    final profileImage = userData['profileImage'] as String? ?? '';

    return {'username': username, 'profileImage': profileImage};
  }

  Stream<List<ChatPartner>> _getOnlineChatPartners() async* {
    final currentUserId = _auth.currentUser?.uid;

    while (true) {
      final chatRooms =
          await FirebaseFirestore.instance
              .collection('chatRooms')
              .where('participants', arrayContains: currentUserId)
              .get();

      final partnerIds =
          chatRooms.docs
              .map(
                (chatRoom) => (chatRoom['participants'] as List<dynamic>)
                    .cast<String>()
                    .firstWhere((id) => id != currentUserId),
              )
              .toSet();

      if (partnerIds.isEmpty) {
        yield [];
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      final onlineUsers =
          await FirebaseFirestore.instance
              .collection('users')
              .where('isOnline', isEqualTo: true)
              .where(FieldPath.documentId, whereIn: partnerIds.toList())
              .get();

      final onlineExperts =
          await FirebaseFirestore.instance
              .collection('experts')
              .where('isOnline', isEqualTo: true)
              .where(FieldPath.documentId, whereIn: partnerIds.toList())
              .get();

      final allPartners = [...onlineUsers.docs, ...onlineExperts.docs];

      // تحويل المستندات إلى كائنات ChatPartner
      final partners = await Future.wait(
        allPartners.map((doc) async {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return ChatPartner(
            id: doc.id,
            name: data['name'] ?? data['username'] ?? 'Unknown',
            email: data['email'] ?? '', // سيستخدم '' إذا لم يوجد حقل email
            photoUrl: data['photoUrl'] ?? data['profileImage'] ?? '',
            specialty: data['specialization'] ?? 'Unknown', // Added specialty
          );
        }),
      );

      yield partners;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<ChatPartner?> _getChatPartnerDetails(String partnerId) async {
    try {
      DocumentSnapshot expertDoc =
          await FirebaseFirestore.instance
              .collection('experts')
              .doc(partnerId)
              .get();

      if (expertDoc.exists) {
        return ChatPartner.fromExpert(expertDoc);
      }

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(partnerId)
              .get();

      if (userDoc.exists) {
        return ChatPartner.fromUser(userDoc);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting partner details: $e');
      return null;
    }
  }

  String _formatLastMessageTime(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays > 7) {
      return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
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
