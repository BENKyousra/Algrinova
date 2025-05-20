import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:algrinova/screens/chat/message_screen.dart';
import 'package:algrinova/widgets/custom_bottom_navbar.dart';


class ChatScreen extends StatefulWidget {
  final String? expertId;
  final String? expertEmail;

  const ChatScreen({super.key, this.expertId, this.expertEmail});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = true;
  String _searchQuery = ''; 

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
    _searchController.dispose();
    super.dispose();
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
    // مثال على بيانات وهمية للدردشات
    final dummyChats =
        [
          {
            'name': 'John Doe',
            'lastMessage': 'Hello there!',
            'time': '2h',
            'unreadCount': 3,
            'imageUrl': 'assets/images/user1.png',
          },
          {
            'name': 'Jane Smith',
            'lastMessage': 'How are you doing?',
            'time': '1d',
            'unreadCount': 1,
            'imageUrl': 'assets/images/user1.png',
          },
          {
            'name': 'Mark Johnson',
            'lastMessage': 'How are you?',
            'time': '5m',
            'unreadCount': 0,
            'imageUrl': 'assets/images/user1.png',
          },
        ].where((chat) {
          final name = chat['name'] as String;
          return name.toLowerCase().startsWith(_searchQuery.toLowerCase());
        }).toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemCount: dummyChats.length,
      itemBuilder: (context, index) {
        final chat = dummyChats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade400,
            radius: 28,
            backgroundImage: AssetImage(
              chat['imageUrl'] as String? ?? 'assets/images/user1.png',
            ),
          ),
          title: Text(
            chat['name']! as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'QuickSand',
            ),
          ),
          subtitle: Text(
            chat['lastMessage']! as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  (chat['unreadCount'] as int) > 0 ? const Color.fromARGB(255, 0, 143, 48) : Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat['time']! as String,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if ((chat['unreadCount'] as int) > 0)
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
                    '${chat['unreadCount']}',
                    style: const TextStyle(fontSize: 10, color: Colors.white , fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => test1(
                        receiverUserId: 'dummy_id',
                        receiverUserEmail: 'dummy@email.com',
                        receiverUserProfileImage:
                            (chat['imageUrl'] as String?) ??
                            'assets/images/user1.png',
                        receiverUserUsername: chat['name']! as String,
                      ),
                ),
              ),
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 0, thickness: 0.5, color: Colors.grey.withOpacity(0.5),
        ),
    );
  }

  Widget _buildOnlineUsersList() {
    // مثال على بيانات وهمية للمستخدمين المتصلين
    final dummyOnlineUsers = [
      {'name': 'Alex', 'imageaUrl': 'assets/images/user1.png'},
      {'name': 'Sarah', 'imageUrl': 'assets/images/user1.png'},
      {'name': 'Mike', 'imageUrl': 'assets/images/user1.png'},
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
                          (context) => test1(
                            receiverUserId: 'dummy_id',
                            receiverUserEmail: 'dummy@email.com',
                            receiverUserProfileImage:
                                user['imageUrl'] ?? 'assets/images/user1.png',
                            receiverUserUsername: user['name']!,
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
                          user['imageUrl'] ?? 'assets/images/user1.png',
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

