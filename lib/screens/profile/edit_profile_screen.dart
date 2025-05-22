import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algrinova/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _imageFile;
  String _photoUrl = ''; // Variable pour stocker l'URL de la photo
  bool _isLoading = true;


  final ImagePicker _picker = ImagePicker();

  // Méthode pour récupérer les informations de l'utilisateur depuis Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          // Remplir les champs avec les anciennes données
          _nameController.text = data['name'] ?? '';
          _emailController.text = user.email ?? '';  // Charger l'email de l'utilisateur
          _locationController.text = data['location'] ?? '';
          _photoUrl = data['photoUrl'] ?? ''; // Charger l'URL de la photo
        }
      } catch (e) {
        print('Erreur lors du chargement des données de l\'utilisateur: $e');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Charger les données de l'utilisateur au démarrage
  }

  // Méthode pour sélectionner une nouvelle photo
  Future<void> _pickImage() async {

  try {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  } catch (e) {
    print("Erreur lors de la sélection de l'image : $e");
  } finally {
    // Afficher un message de confirmation ou d'erreur
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image sélectionnée')),
    );
  }

}


  // Méthode pour enregistrer les modifications de profil
void _saveProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  final newEmail = _emailController.text.trim();
  final oldEmail = user?.email;

  if (user != null) {
    final userService = UserService();

    if (_nameController.text.isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tous les champs doivent être remplis.')),
      );
      return;
    }

    try {
      // ✅ Étape 1 : Tenter de changer l'email s'il a changé
      if (newEmail != oldEmail) {
        try {
          await user.updateEmail(newEmail);
          print("✅ Email Firebase mis à jour !");
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            // 🔐 Demander le mot de passe pour réauthentification
            final passwordController = TextEditingController();
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Confirmation requise'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Pour changer l'email, entrez votre mot de passe :"),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Mot de passe'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Fermer le dialogue
                      try {
                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: passwordController.text.trim(),
                        );
                        await user.reauthenticateWithCredential(credential);
                        print("🔁 Ré-authentifié avec succès");

                        await user.updateEmail(newEmail);
                        print("✅ Email mis à jour après réauthentification !");
                      } catch (err) {
                        print("❌ Erreur de réauthentification ou d'updateEmail : $err");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erreur : ${err.toString()}")),
                        );
                      }
                    },
                    child: Text('Valider'),
                  ),
                ],
              ),
            );
          } else {
            throw e;
          }
        }
      }

      // ✅ Étape 2 : mise à jour des données Firestore + image
      await userService.updateUserProfileWithImage(
        uid: user.uid,
        data: {
          'name': _nameController.text.trim(),
          'email': newEmail,
          'location': _locationController.text.trim(),
        },
        imageFile: _imageFile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil mis à jour avec succès')),
      );
    } on FirebaseAuthException catch (e) {
      print("❌ Erreur Firebase : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur Firebase : ${e.message}')),
      );
    } catch (e, stacktrace) {
      print("❌ Exception dans _saveProfile : $e");
      print("🧱 Stacktrace : $stacktrace");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }
}



  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (_photoUrl.isNotEmpty
                        ? NetworkImage(_photoUrl)
                        : AssetImage('assets/images/default_profile.png')
                            as ImageProvider),
                child: _imageFile == null && _photoUrl.isEmpty
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 143, 48)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 0, 143, 48)),
                ),
              ),
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 143, 48)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 0, 143, 48)),
                ),
              ),
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 143, 48)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 0, 143, 48)),
                ),
              ),
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: _saveProfile,
              child: Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
