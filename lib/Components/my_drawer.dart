import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_tiles/my_list_tile.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/Screens/card/user_cards_screen.dart';
import 'package:personalwallettracker/Screens/categories/catogories_screen.dart';
import 'package:personalwallettracker/Screens/home.dart';
import 'package:personalwallettracker/Screens/onboarding/onboarding_screen.dart';
import 'package:personalwallettracker/Screens/profile_screen.dart';
import 'package:personalwallettracker/Screens/settings_screen.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';
import '../Models/card_model.dart';
import '../Screens/transaction/recurring_transactions/recurring_transactions_screen.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/login_register_screen.dart';
import '../Utils/globals.dart';

class MyDrawer extends StatefulWidget {
  final User user;
  final Person personProfile;
  final List<CardModel> myCards;
  const MyDrawer(
      {super.key,
      required this.user,
      required this.personProfile,
      required this.myCards});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  FirebaseDB fbdatabaseHelper = FirebaseDB();
  AuthService authService = AuthService();

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
                  // Profile picture and email
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.pink,
                    ),
                    accountName: Text(
                      '${widget.personProfile.username} ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    accountEmail: Text(
                      widget.personProfile.email,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: widget
                              .personProfile.profile_picture.isNotEmpty
                          ? NetworkImage(widget.personProfile.profile_picture)
                          : const NetworkImage(
                              'https://icons.veryicon.com/png/o/miscellaneous/common-icons-31/default-avatar-2.png',
                            ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  // Reload
                  MyListTile(
                    icon: const Icon(Icons.refresh),
                    tileTitle: 'Reload!',
                    onTap: navHomePage,
                  ),
                  // Profile Screen
                  MyListTile(
                    icon: const Icon(Icons.person_2_outlined),
                    tileTitle: 'Profile',
                    onTap: navProfile,
                  ),
                  // Categories Screen
                  MyListTile(
                      icon: const Icon(Icons.category_outlined),
                      tileTitle: 'Categories',
                      onTap: navCategoriesScreen),
                  // Cards List Sreen
                  MyListTile(
                      icon: const Icon(Icons.payment_outlined),
                      tileTitle: 'My Cards',
                      onTap: navUserCardsScreen),
                  // Recurring Transactions
                  MyListTile(
                      icon: const Icon(Icons.history),
                      tileTitle: 'Recurring Transactions',
                      onTap: navRecurringTransactionScreen),
                  // Settings
                  MyListTile(
                      icon: const Icon(Icons.settings),
                      tileTitle: 'Settings',
                      onTap: navSettingsPage),
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

  void navRecurringTransactionScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return RecurringTransactionsScreen(
        user: widget.user,
        personProfile: widget.personProfile,
        myCards: widget.myCards,
      );
    }));
  }

  void navProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MyProfileScreen(
        user: widget.user,
        personProfile: widget.personProfile,
      );
    }));
  }

  void navSettingsPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingsScreen(person: widget.personProfile);
    }));
  }

  void navHomePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const MyHomePage();
    }));
  }

  void navCategoriesScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const CategoriesScreen();
    }));
  }

  void navUserCardsScreen() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CardListScreen(
        currency: widget.personProfile.default_currency,
      );
    }));
  }

  void navOnboardingScreen() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const OnboardingScreen();
    }));
  }
}
