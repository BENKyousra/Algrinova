import 'package:flutter/material.dart';
import 'dart:io';
import 'package:algrinova/main.dart';
import 'package:algrinova/screens/profile/edit_profile_screen.dart';
import 'package:algrinova/screens/profile/change_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:algrinova/services/user_service.dart';

final UserService _userService = UserService();

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

Future<String> demanderMotDePasse(BuildContext context) async {
  String password = '';
  bool confirmPressed = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Confirmation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Veuillez entrer votre mot de passe pour confirmer.'),
          TextField(
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
            decoration: InputDecoration(
              hintText: 'Mot de passe',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Annuler'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'Confirmer',
            style: TextStyle(color: Color.fromARGB(255, 255, 47, 92)),
          ),
          onPressed: () {
            confirmPressed = true;
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );

  if (!confirmPressed || password.isEmpty) throw Exception('Opération annulée');
  return password;
}


class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = AlgrinovaApp.themeNotifier.value == ThemeMode.dark;
  String selectedLanguage = 'English';

  // GlobalKey pour manipuler le ScaffoldMessenger hors du context classique
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              title: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              flexibleSpace: Image.asset(
                'assets/images/blur.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 10),
            ListTile(
              title: Text('Edit Profile'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              },
            ),
            SwitchListTile(
              secondary: Icon(Icons.dark_mode),
              title: Text('Dark Mode'),
              activeColor: Color.fromARGB(255, 0, 143, 48),
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                  AlgrinovaApp.themeNotifier.value =
                      value ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
              subtitle: Text(selectedLanguage),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(
                            'Français',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            setState(() => selectedLanguage = 'Français');
                            AlgrinovaApp.localeNotifier.value = Locale('fr');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text('العربية'),
                          onTap: () {
                            setState(() => selectedLanguage = 'العربية');
                            AlgrinovaApp.localeNotifier.value = Locale('ar');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text('English',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () {
                            setState(() => selectedLanguage = 'English');
                            AlgrinovaApp.localeNotifier.value = Locale('en');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('About Algrinova'),
                    content: Text(
                      'Algrinova is an innovative application designed to help you with your agricultural needs.\n\n'
                      'Our mission is to provide easy access to plants, seeds, and agricultural tools, '
                      'as well as a platform for connecting with experts and receiving valuable advice.',
                    ),
                    actions: [
                      TextButton(
                        child: Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Color.fromARGB(255, 255, 47, 92)),
              title: Text(
                'Delete my account',
                style: TextStyle(color: Color.fromARGB(255, 255, 47, 92)),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirmation'),
                    content: Text(
                        'Are you sure you want to delete your account? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text('Yes, delete',
                            style: TextStyle(color: Color.fromARGB(255, 255, 47, 92))),
                        
onPressed: () async {
    Navigator.pop(context); // Ferme la boîte de dialogue

    try {
      final password = await demanderMotDePasse(context);

      await _userService.deleteUser(password: password);
      await FirebaseAuth.instance.signOut(); 
      await Future.delayed(Duration(milliseconds: 500));

      if (!mounted) return;

      // Fermer complètement l'application après suppression
      exit(0);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Mot de passe incorrect.';
          break;
        case 'requires-recent-login':
          message = 'Veuillez vous reconnecter avant de supprimer le compte.';
          break;
        default:
          message = 'Erreur : ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inattendue : $e')),
      );
    }
  },

                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Color.fromARGB(255, 255, 47, 92)),
              title: Text('Log out',
                  style: TextStyle(color: Color.fromARGB(255, 255, 47, 92))),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Log Out'),
                    content: Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text('Yes',
                            style: TextStyle(color: Color.fromARGB(255, 255, 47, 92))),
                        onPressed: () async {
  Navigator.pop(context);
  Navigator.pop(context);
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacementNamed(context, '/login');
},

                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
