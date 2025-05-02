import 'package:flutter/material.dart';
import 'package:algrinova/screens/home/home_screen.dart';
import 'package:algrinova/screens/login/login_screen.dart';

class CreateAccountScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // خلفية الصورة
          Positioned.fill(
            child: Image.asset(
              'assets/images/vecteezy_green-plant-leaves-in-nature_1990614.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // المحتوى
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    const Center(
                      child: Text(
                        'Create new account',
                        style: TextStyle(
                          fontFamily: 'Lobster',
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildTextField('Username', usernameController),
                    const SizedBox(height: 15),

                    _buildTextField('Email or Number', emailController),
                    const SizedBox(height: 15),

                    _buildTextField('Password', passwordController, obscure: true),
                    const SizedBox(height: 15),

                    _buildTextField('Confirm Password', confirmPasswordController, obscure: true),
                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: const Text(
                        "  Already have an account ? Log in",
                        style: TextStyle(color: Color.fromARGB(255, 229, 255, 232),fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const Spacer(),
                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 0, 143, 48), Color.fromARGB(255, 0, 41, 14)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}