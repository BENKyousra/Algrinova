import 'package:algrinova/l10n/generated/l10n.dart';
import 'package:algrinova/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:algrinova/screens/home/home_screen.dart';
import 'package:algrinova/screens/profile/profile_screen.dart';
import 'package:algrinova/screens/login/login_screen.dart';
import 'package:algrinova/screens/experts/experts_screen.dart';
import 'package:algrinova/screens/store/store_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:algrinova/provider/cart_provider.dart';
import 'package:algrinova/screens/chat/chat_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Rendre la barre de statut transparente
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: const Color.fromARGB(0, 255, 255, 255),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: const Color.fromARGB(255, 0, 0, 0),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(MultiProvider(
    
      providers: [
        ChangeNotifierProvider<AuthService>(  // Utilisation de ChangeNotifierProvider ici
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: AlgrinovaApp(),
    ),
  );
}

class AlgrinovaApp extends StatefulWidget {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
  static final localeNotifier = ValueNotifier<Locale>(Locale('en')); // Valeur initiale : Français

  @override
  State<AlgrinovaApp> createState() => _AlgrinovaAppState();
}

class _AlgrinovaAppState extends State<AlgrinovaApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AlgrinovaApp.themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          locale: AlgrinovaApp.localeNotifier.value,
          supportedLocales: const [
            Locale('fr'), // Français
            Locale('ar'), // Arabe
            Locale('en'), // Anglais
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate,// N'oublie pas d'ajouter la localisation custom
          ],
          themeMode: currentMode,  // Utilisation de themeMode ici
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: 'Quicksand',
            primaryColor:  Color.fromARGB(255, 255, 255, 255), // Couleur principale de l'application
            // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color.fromARGB(255, 0, 143, 48)), // Couleur pour les éléments interactifs
            textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Color.fromARGB(255, 0, 143, 48)), // Couleur des TextButton
    ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Quicksand',
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/home',
          routes: {
            '/home': (context) => HomeScreen(),
            '/experts': (context) => ExpertsScreen(),
            '/store': (context) => StoreScreen(),
            '/chat': (context) => ChatScreen(),
            '/profile': (context) => ProfileScreen(),
            '/login': (context) => LoginScreen(),
          },
          home: HomeScreen(),
        );
      },
    );
  }
}