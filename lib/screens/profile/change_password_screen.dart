import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  Future<void> _reauthenticate(String oldPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'Aucun utilisateur connecté.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> _changePassword() async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le nouveau mot de passe ne correspond pas.")),
      );
      return;
    }

    try {
      await _reauthenticate(oldPassword);
      await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mot de passe mis à jour avec succès.")),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Erreur : ${e.message}";
      if (e.code == 'wrong-password') message = "Ancien mot de passe incorrect.";
      if (e.code == 'weak-password') message = "Le nouveau mot de passe est trop faible.";
      if (e.code == 'requires-recent-login') message = "Veuillez vous reconnecter.";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password", style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold, ))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 143, 48)),
                focusColor: Color.fromARGB(255, 0, 143, 48),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 0, 143, 48)),
                ),
              ),
              cursorColor: Color.fromARGB(255, 0, 143, 48),
              textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 143, 48)),
                focusColor: Color.fromARGB(255, 0, 143, 48),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 0, 143, 48)),
                ),
              ),
              cursorColor: Color.fromARGB(255, 0, 143, 48),
              textInputAction: TextInputAction.done,
              ),
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 143, 48)),
                focusColor: Color.fromARGB(255, 0, 143, 48),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 0, 143, 48)),
                ),
              ),
              cursorColor: Color.fromARGB(255, 0, 143, 48),
              textInputAction: TextInputAction.done,
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
              onPressed: _changePassword,
              child: Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
              
            ],
          ),
        ),
      ),
    );
  }
}
