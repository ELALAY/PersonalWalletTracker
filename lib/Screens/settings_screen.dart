import 'package:flutter/material.dart';
import 'package:personalwallettracker/Utils/globals.dart';

import 'card/user_cards_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = darkTheme;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkTheme = value;
      darkTheme = value; // Update the global darkTheme variable
    });

    // Here you would add the logic to actually apply the theme.
    // For example, using a ThemeNotifier with Provider or another state management solution.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent ,
        elevation: 0.0,
        foregroundColor: darkTheme? Colors.white : Colors.grey,
      ),
      body: Column(
        children:[
          const SizedBox(height: 20.0,),
          SwitchListTile(
            value: _isDarkTheme,
            title: const Text('Dark Theme'),
            tileColor:darkTheme ? Colors.grey : Colors.grey.shade200,
            onChanged: _toggleTheme,
            activeColor: Colors.black,
            
          ),
          const SizedBox(height: 20.0,),
          ListTile(
            title: const Text('My Cards'),
            leading: const Icon(Icons.payment_outlined),
            trailing: const Icon(Icons.arrow_forward_ios),
            tileColor:darkTheme ? Colors.grey : Colors.grey.shade200,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CardListScreen();
              }));
            },
          ),
        ]
      ),
    );
  }
}
