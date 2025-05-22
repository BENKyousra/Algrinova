import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algrinova/screens/experts/experts_profile_screen.dart';

class ExpertsListScreen extends StatelessWidget {
  const ExpertsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tous les Experts")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'expert')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun expert trouvé."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              final expertId = docs[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty)
                        ? NetworkImage(data['photoUrl'])
                        : const AssetImage("assets/images/default_profile.png") as ImageProvider,
                  ),
                  title: Text(data['name'] ?? 'Nom inconnu'),
                  subtitle: Text(data['specialty'] ?? 'Spécialité inconnue'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpertProfileScreen(expertId: expertId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
