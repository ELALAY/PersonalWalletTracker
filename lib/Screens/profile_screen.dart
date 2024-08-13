import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';

import '../services/auth/auth_service.dart';

class MyProfileScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic> personProfile;
  const MyProfileScreen({super.key, required this.user, required this.personProfile});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  AuthService authService = AuthService();
  //loading screen
  bool isLoading = true;
  //key info to edit
  bool enabledEditkeyInfo = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
        actions: [
          CupertinoSwitch(
              value: enabledEditkeyInfo,
              onChanged: (value) {
                setState(() {
                  enabledEditkeyInfo = value;
                });
              })
        ],
      ),
      body: isLoading ?
        const Center(child: CircularProgressIndicator(),)
        : SingleChildScrollView(child: Column(children: [],),),
    );
  }
}
