import 'package:flutter/material.dart';


class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex, // ✅ Assure que les labels restent visibles
      selectedItemColor: Color.fromARGB(255, 0, 143, 48),
      unselectedItemColor: Color.fromRGBO(80, 80, 80, 1),
      showSelectedLabels: true, // ✅ Garde le texte affiché
      showUnselectedLabels: true, // ✅ Garde aussi les labels gris
      iconSize: 20,
      selectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 14),
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(this.context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(this.context, '/experts');
            break;
          case 2:
            Navigator.pushReplacementNamed(this.context, '/chat');
            break;
          case 3:
            Navigator.pushReplacementNamed(this.context, '/store');
            break;
          case 4:
            Navigator.pushReplacementNamed(this.context, '/profile');
            break;
        }
        },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: "Experts"),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_rounded),
          label: "Chat",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: "Store",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }
}
