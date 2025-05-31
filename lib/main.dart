import 'package:algrinova/l10n/generated/l10n.dart';
import 'package:algrinova/services/auth_service.dart';
import 'package:algrinova/services/user_service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:algrinova/screens/home/home_screen.dart';
import 'package:algrinova/screens/experts/expert_profile_my_screen.dart';
import 'package:algrinova/screens/login/login_screen.dart';
import 'package:algrinova/screens/experts/experts_screen.dart';
import 'package:algrinova/screens/store/store_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:algrinova/provider/cart_provider.dart';
import 'package:algrinova/screens/chat/chat_screen.dart';
import 'package:algrinova/screens/profile/profile_my_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:algrinova/screens/chat/message_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: const Color.fromARGB(0, 0, 0, 0),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: AlgrinovaApp(),
    ),
  );
}

class AlgrinovaApp extends StatefulWidget {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.light,
  );
  static final localeNotifier = ValueNotifier<Locale>(Locale('en'));

  const AlgrinovaApp({super.key});

  @override
  State<AlgrinovaApp> createState() => _AlgrinovaAppState();
}

class _AlgrinovaAppState extends State<AlgrinovaApp>
    with WidgetsBindingObserver {
  final UserService _userService = UserService();
  String? userRole;
  String? userId;
  bool isLoading = true;
  String? _initialDeepLink;


  @override
  void initState() {
    super.initState();
    _getInitialDynamicLink();
    WidgetsBinding.instance.addObserver(this);
    _listenToAuthChanges();
    checkUserRole();
  }

  Future<void> _getInitialDynamicLink() async {
  final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
  final Uri? deepLink = data?.link;

  if (deepLink != null) {
    setState(() {
      _initialDeepLink = deepLink.toString();
    });
  }
}


  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        userId = user.uid;
        _userService.updateOnlineStatus(user.uid, true); // connecté
      } else {
        if (userId != null) {
          _userService.updateOnlineStatus(userId!, false); // déconnecté
        }
        userId = null;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (userId == null) return;

    if (state == AppLifecycleState.resumed) {
      _userService.updateOnlineStatus(userId!, true);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _userService.updateOnlineStatus(userId!, false);
    }
  }

  Future<void> checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        userRole = null;
        isLoading = false;
      });
    } else {
      String role = await _userService.getUserRole(user.uid);
      userId = user.uid;
      setState(() {
        userRole = role;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AlgrinovaApp.themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            Widget homeScreen;
final user = snapshot.data;

if (_initialDeepLink != null) {
  final uri = Uri.parse(_initialDeepLink!);

  if (uri.pathSegments.contains('expert') && uri.pathSegments.length >= 2) {
    final expertId = uri.pathSegments[1];
    homeScreen = ExpertProfileMyScreen(expertId: expertId);
  } else {
    homeScreen = LoginScreen();
  }
} else {
  if (userRole == 'expert') {
    homeScreen = HomeScreen();
  } else if (userRole == 'user') {
    homeScreen = HomeScreen();
  } else if (user == null) {
    homeScreen = LoginScreen();
  } else {
    homeScreen = LoginScreen();
  }
}


            return MaterialApp(
              locale: AlgrinovaApp.localeNotifier.value,
              supportedLocales: const [
                Locale('fr'),
                Locale('ar'),
                Locale('en'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                AppLocalizations.delegate,
              ],
              themeMode: currentMode,
              theme: ThemeData(
                brightness: Brightness.light,
                fontFamily: 'Quicksand',
                primaryColor: Colors.white,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF008F30),
                  ),
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                fontFamily: 'Quicksand',
              ),
              debugShowCheckedModeBanner: false,
              home:
                  homeScreen, // <--- l'écran d'accueil dynamique selon le rôle
              routes: {
                '/home': (context) => HomeScreen(),
                '/experts': (context) => ExpertsScreen(),
                '/store': (context) => StoreScreen(),
                '/chat': (context) => ChatScreen(),
                '/message': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>? ??
                      {};
                  return MessageScreen(
                    receiverUserId: args['userId'] ?? '',
                    receiverUserEmail: args['userEmail'] ?? '',
                    receiverUserphotoUrl: args['userPhotoUrl'] ?? '',
                    receivername:
                        args['userName'] ??
                        '', // TODO: Provide actual user name
                  );
                },
                '/profile':
                    (context) =>
                        userRole == 'expert'
                            ? ExpertProfileMyScreen(
                              expertId:
                                  FirebaseAuth.instance.currentUser?.uid ?? '',
                            )
                            : ProfileMyScreen(),
                '/login': (context) => LoginScreen(),
              },
            );
          },
        );
      },
    );
  }
}
