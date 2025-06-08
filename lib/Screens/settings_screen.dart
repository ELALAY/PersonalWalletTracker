import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/Utils/globals.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';
import 'card/user_cards_screen.dart';
import 'categories/catogories_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Person person;
  final String user;
  const SettingsScreen({super.key, required this.person, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FirebaseDB firebaseDB = FirebaseDB();

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.person.default_currency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20.0),
          // Currency Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Currency',
                  style: TextStyle(fontSize: 16.0),
                ),
                DropdownButton<String>(
                  value: selectedCurrency,
                  items: currencies.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (String? newCurrency) {
                    setState(() {
                      selectedCurrency = newCurrency!;
                      updateUserCurrency();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          // Cards
          ListTile(
            title: const Text('My Cards'),
            leading: const Icon(Icons.payment_outlined),
            trailing: const Icon(Icons.payment_outlined),
            tileColor: Colors.grey.shade200,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CardListScreen(
                  currency: widget.person.default_currency,
                );
              }));
            },
          ),
          const SizedBox(height: 20.0),
          // Categories
          ListTile(
            title: const Text('Categories'),
            leading: const Icon(Icons.payment_outlined),
            trailing: const Icon(Icons.category_outlined),
            tileColor: Colors.grey.shade200,
            onTap: navCategoriesScreen,
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  void navCategoriesScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return  CategoriesScreen(user: widget.user,);
    }));
  }

  void updateUserCurrency() {
    try {
      firebaseDB.updateUserCurrency(widget.person.id, selectedCurrency);
      showInfoSnachBar('You might need to RELOAD!');
    } catch (e) {
      // Log the error with a specific message
      debugPrint('Failed to update currency: $e');
    }
  }

  void showErrorSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.amber.shade400),
        backgroundColor: Colors.amber,
        icon: const Icon(
          Icons.close,
          color: Colors.white,
        ));
  }

  void showInfoSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.lightBlueAccent.shade400),
        backgroundColor: Colors.lightBlueAccent,
        icon: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ));
  }

  void showSuccessSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.green.shade400),
        backgroundColor: Colors.green,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ));
  }
}
