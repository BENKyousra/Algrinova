import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _changePassword() {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le nouveau mot de passe ne correspond pas.")),
      );
      return;
    }

    // TODO: Ajouter ici la logique de vérification et mise à jour du mot de passe via Firebase ou autre backend

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Mot de passe mis à jour avec succès.")),
    );

    // Facultatif : Revenir à l'écran précédent
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Changer le mot de passe"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
      labelText: 'Old password',
      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 143, 48)),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 0, 143, 48)), // Couleur de la ligne lorsqu'il est focus
      ),
    ),
    cursorColor: Colors.black,
    style: TextStyle(color: Colors.black),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
      labelText: 'New password',
      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 143, 48)),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 0, 143, 48)), // Couleur de la ligne lorsqu'il est focus
      ),
    ),
    cursorColor: Colors.black,
    style: TextStyle(color: Colors.black),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
      labelText: 'Confirm password',  
      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 143, 48)),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 0, 143, 48)), // Couleur de la ligne lorsqu'il est focus
      ),
    ),
    cursorColor: Colors.black,
    style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: _changePassword,
              child: Text("Mettre à jour le mot de passe",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
