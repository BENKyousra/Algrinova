import 'dart:async';
import 'package:flutter/material.dart';
import 'package:algrinova/screens/login/reset_password.dart'; // ← تأكد من وجود هذا الملف والكلاس

class OTPVerificationScreen extends StatefulWidget {
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  List<TextEditingController> controllers = List.generate(4, (_) => TextEditingController());
  Timer? _timer;
  int _start = 60; // ← دقيقة واحدة

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus(); // Ferme le clavier quand on tape ailleurs
    },
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/vecteezy_green-plant-leaves-in-nature_1990614.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    _buildGlassText("You received a PIN code in your email, please enter it"),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return _buildPinBox(controllers[index]);
                      }),
                    ),
                    const SizedBox(height: 20),
                    Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Icon(Icons.timer, color: Colors.white),
    const SizedBox(width: 5),
    Text(
      '00:${_start.toString().padLeft(2, '0')}',
      style: const TextStyle(color: Colors.white, fontSize: 19),
    ),
    const SizedBox(width: 5),
    IconButton(
      onPressed: () {
        setState(() {
          _start = 60;
        });
        _timer?.cancel();
        startTimer();

        // Simuler l’envoi d’un nouveau PIN
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A new PIN has been sent to your email.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      icon: Icon(Icons.refresh, color: Colors.white),
      tooltip: "Resend PIN and restart timer",
    ),
  ],
),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResetPassword()),
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
                        'Next',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "If you didn't receive the code,\nplease try again",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 150, 174, 156),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPinBox(TextEditingController controller) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        cursorColor: Colors.white,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 24,fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildGlassText(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:const Color.fromARGB(158, 0, 143, 48),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}