import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/login_register_screen.dart';
import '../Utils/globals.dart';
import 'mylisttile.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  FirebaseDB fbdatabaseHelper = FirebaseDB();
  AuthService authService = AuthService();

  User? user;
  Map<String, dynamic>? personProfile;

  void fetchUser() async {
    try {
      User? userTemp = authService.getCurrentUser();
      if (userTemp != null) {
        Map<String, dynamic>? personProfileTemp =
            await fbdatabaseHelper.getPersonProfile(userTemp.uid);
        setState(() {
          user = userTemp;
          personProfile = personProfileTemp;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }

  void logout() async {
    try {
      await authService.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: darkTheme ? Colors.grey.shade600 : Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                    ),
                    accountName: Text(
                      '${personProfile?['username'] ?? 'No username'} ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    accountEmail: Text(
                      '${personProfile?['email'] ?? 'No email'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: personProfile?['profile_picture'] != null
                          ? NetworkImage(personProfile!['profile_picture'])
                          : const NetworkImage(
                              'https://icons.veryicon.com/png/o/miscellaneous/common-icons-31/default-avatar-2.png',
                            ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SwitchListTile(
                    activeColor: Colors.deepPurple.shade300,
                    inactiveTrackColor: Colors.deepPurple.shade300,
                    inactiveThumbColor: Colors.white,
                    activeTrackColor: Colors.white,
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: darkTheme ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: darkTheme,
                    onChanged: (bool value) {
                      setState(() {
                        darkTheme = value;
                      });
                    },
                    secondary: darkTheme
                        ? const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.black,
                          ),
                  ),
                  
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 1.0),
              ),
            ),
            child: ListTile(
              title: Text(
                'Logout',
                style: TextStyle(
                  color: darkTheme ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }

  // void navProfile() {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) {
  //     return const MyProfile();
  //   }));
  // }

  // void navFriends() {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) {
  //     return const MyFriendsScreen();
  //   }));
  // }
}
