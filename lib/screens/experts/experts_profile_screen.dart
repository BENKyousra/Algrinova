import 'package:algrinova/screens/chat/message_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algrinova/services/user_service.dart'; // ici on importe UserService
import 'package:algrinova/widgets/custom_bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ExpertProfileScreen extends StatelessWidget {
  final String expertId;
  
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  ExpertProfileScreen({super.key, required this.expertId});

  @override
  Widget build(BuildContext context) {
    final UserService _userService = UserService();

    return Scaffold(
      bottomNavigationBar: CustomBottomNavBar(
        context: context,
        currentIndex: 1,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(expertId).snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Expert introuvable."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Vérifier que le rôle est bien "expert"
          if (data['role'] != 'expert') {
            return const Center(child: Text("Ce profil n'est pas un expert."));
          }

          final String name = data['name'] ?? 'Nom inconnu';
          final String specialty = data['specialty'] ?? 'Spécialité inconnue';
          final String location = data['location'] ?? 'Ville inconnue';
          final String photoUrl = data['photoUrl'] ?? '';
          
          final userData = snapshot.data!;
          final bool isOnline = userData['isOnline'] ?? false;

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
                                  Positioned(
                                          top: 40,
                                          left: 16,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                    Positioned(
        top: 90,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: photoUrl != ""
                    ? NetworkImage(photoUrl)
                    : const AssetImage("assets/images/pexels-olly-3756616.jpg")
                        as ImageProvider,
              ),
            ),
      Positioned(
        bottom: 6,
        right: 6,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: data['isOnline'] == true ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    ],
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
                      const SizedBox(height: 4),
                      Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      specialty,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.grey,
      ),
    ),
    const SizedBox(width: 8),
    const Icon(Icons.star, color: Colors.amber, size: 20),
    Text(
      (data['rating'] ?? 0).toStringAsFixed(1),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    ),
  ],
),

                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_pin,
                            size: 20,
                            color: Color.fromRGBO(80, 80, 80, 1),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(80, 80, 80, 1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),         
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    receiverUserId: expertId,
                                    receiverUserEmail: data['email'] ?? '',
                                    receiverUserphotoUrl: photoUrl,
                                    receivername: name,
                                  ),
                                ),
                              );
                            },
                            label: const Text(
                              "Contacter",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Divider(
  thickness: 1,
  color: Colors.grey,
  indent: 40,
  endIndent: 40,
),
const SizedBox(height: 5),
                      const Text(
                        "Publications récentes",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 143, 48),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 🔽 Affichage des posts 🔽
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('posts')
                            .where('userId', isEqualTo: expertId)
                            .orderBy('timestamp', descending: true)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("Aucune publication disponible."),
                            );
                          }

                          final posts = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index].data() as Map<String, dynamic>;
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (post['imageUrl'] != null && post['imageUrl'] != '')
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(post['imageUrl']),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        post['text'] ?? '',
                                       ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
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
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
