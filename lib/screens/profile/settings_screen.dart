import 'package:flutter/material.dart';
import 'package:algrinova/main.dart';
import 'package:algrinova/screens/profile/edit_profile_screen.dart';
import 'package:algrinova/screens/profile/change_password_screen.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = AlgrinovaApp.themeNotifier.value == ThemeMode.dark;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            title: Text(
              'Edit Profile'),
            leading: Icon(Icons.person),
            onTap: () {
              Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => EditProfileScreen()),
);

              // To implement: Navigate to profile edit screen
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
                AlgrinovaApp.themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
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
  leading: Icon(Icons.delete_forever, color:Color.fromARGB(255, 255, 47, 92)),
  title: Text('Delete my account', style: TextStyle(color:Color.fromARGB(255, 255, 47, 92))),
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Yes, delete', style: TextStyle(color:Color.fromARGB(255, 255, 47, 92))),
            onPressed: () {
              Navigator.pop(context); // Ferme la boîte de dialogue
              Navigator.pushReplacementNamed(context, '/login'); // Simule une redirection
              // TODO plus tard : ajouter ici la vraie suppression depuis Firebase ou ton backend
            },
          ),
        ],
      ),
    );
  },
),

          ListTile(
            leading: Icon(Icons.logout, color:Color.fromARGB(255, 255, 47, 92)),
            title: Text('Log out', style: TextStyle(color:Color.fromARGB(255, 255, 47, 92))),
            onTap: () {
              // Show confirmation dialog
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
                      child: Text('Yes', style: TextStyle(color: Color.fromARGB(255, 255, 47, 92))),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/login');
                        // TODO: Add logout logic here (e.g., remove tokens)
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
    );
  }
}
