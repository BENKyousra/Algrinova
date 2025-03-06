import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:algrinova/home_screen.dart';

void main() {
   // Rendre la barre de statut transparente
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: const Color.fromARGB(0, 255, 255, 255), // 🔥 Rend la barre de statut transparente
    statusBarIconBrightness: Brightness.light, // Icônes en blanc (utilise `dark` pour les avoir en noir)
    systemNavigationBarColor: const Color.fromARGB(255, 0, 0, 0), // Changer la couleur de la barre de navigation en bas
    systemNavigationBarIconBrightness: Brightness.light, // Icônes en blanc
  ));
  runApp(AlgrinovaApp());
}

class AlgrinovaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}