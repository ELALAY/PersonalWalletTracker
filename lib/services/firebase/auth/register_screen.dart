import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Components/my_textfields/my_emailfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_pwdfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/Screens/onboarding/onboarding_screen.dart';
import 'package:personalwallettracker/services/firebase/claoud_storage_db/firebase_storage.dart';
import '../realtime_db/firebase_db.dart';
import 'auth_service.dart';
import 'login_register_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  FirebaseDB fbdatabaseHelper = FirebaseDB();
  FirebaseCloudStorageHelper firebaseCloudStorageHelper = FirebaseCloudStorageHelper();
  final authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  File? _profileImage;
  String errorMessage = '';
  User? user;

  Future<void> saveUsername() async {
    String username = usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        errorMessage = 'Username cannot be empty';
        showErrorSnachBar(errorMessage);
      });
      return;
    }

    bool usernameExists = await checkUsernameAvailability(username);

    if (usernameExists) {
      setState(() {
        errorMessage = 'Username is already taken';
        showErrorSnachBar(errorMessage);
      });
    } else {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await firebaseCloudStorageHelper.uploadProfileImage(_profileImage!);
      } else {
        profileImageUrl =
            'https://icons.veryicon.com/png/o/miscellaneous/common-icons-31/default-avatar-2.png';
      }

      Person personProfile = Person.fromMap({
        'username': username,
        'email': user!.email,
        'profile_picture': profileImageUrl,
      }, user!.uid);

      await FirebaseFirestore.instance
          .collection('persons')
          .doc(user!.uid)
          .set(personProfile.toMap());

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    }
  }

  Future<bool> checkUsernameAvailability(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('persons')
        .where('username', isEqualTo: username)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      showErrorSnachBar(errorMessage);
      return;
    }
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      setState(() {
        errorMessage = 'invalid email';
      });
      showErrorSnachBar(errorMessage);
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      user = authService.getCurrentUser();
      saveUsername();
      // Navigate to another screen or show success message
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The account already exists for that email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
        showErrorSnachBar(errorMessage);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
        showErrorSnachBar(errorMessage);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        // Optionally convert to Uint8List if needed
        Uint8List imageBytes = await _profileImage!.readAsBytes();
        debugPrint('Image picked and converted to bytes: $imageBytes');
      } else {
        debugPrint('No image selected.');
        showErrorSnachBar('No image selected!');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      showErrorSnachBar('Error picking image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        foregroundColor: Colors.grey,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                _profileImage != null
                    ? CircleAvatar(
                        radius: 64,
                        backgroundImage: FileImage(_profileImage!),
                        backgroundColor: Colors.deepPurple,
                      )
                    : const CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(
                            'https://icons.veryicon.com/png/o/miscellaneous/common-icons-31/default-avatar-2.png'),
                        backgroundColor: Colors.deepPurple,
                      ),
                Positioned(
                  bottom: -15,
                  left: -10,
                  child: IconButton(
                      onPressed: _pickProfileImage,
                      icon: const Icon(Icons.add_a_photo_outlined)),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Register to ScoreBuddy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(
              height: 40,
            ),
            //Username Field
            MyTextField(
                controller: usernameController,
                label: 'Username',
                color: Colors.deepPurple,
                enabled: true),
            const SizedBox(
              height: 10,
            ),
            //Email Field
            MyEmailField(
                controller: emailController,
                label: 'Email',
                color: Colors.deepPurple,
                enabled: true),
            const SizedBox(
              height: 10,
            ),
            MyPwdField(
                controller: passwordController,
                label: 'Password',
                color: Colors.deepPurple,
                enabled: true),
            const SizedBox(
              height: 10,
            ),
            MyPwdField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                color: Colors.deepPurple,
                enabled: true),
            const SizedBox(
              height: 20,
            ),
            //Register button
            MyButton(label: 'Register', onTap: register),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: navLogin,
              child: const Row(
                children: [
                  Text('Already a member?'),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Login Now!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const LoginOrRegister();
    }));
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
