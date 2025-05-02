import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery, // ou ImageSource.camera
      imageQuality: 80,
    );

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void _saveProfile() {
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();

    // Example usage of email and phone variables
    print('Email: $email, Phone: $phone');

    // TODO: Envoyer ces données + image vers Firebase ou backend

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
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
        borderSide: BorderSide(color: Color.fromARGB(255, 0, 143, 48)), // Couleur de la ligne lorsqu'il est focus
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
        borderSide: BorderSide(color: Color.fromARGB(255, 0, 143, 48)), // Couleur de la ligne lorsqu'il est focus
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
