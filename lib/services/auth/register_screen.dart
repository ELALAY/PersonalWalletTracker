import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import '../../Screens/home.dart';
import '../../Utils/globals.dart';
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
      });
      return;
    }

    bool usernameExists = await checkUsernameAvailability(username);

    if (usernameExists) {
      setState(() {
        errorMessage = 'Username is already taken';
      });
    } else {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _uploadProfileImage(_profileImage!);
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
          builder: (context) => const MyHomePage(),
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
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(errorMessage),
              ));
      return;
    }
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      setState(() {
        errorMessage = 'invalid email';
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(errorMessage),
              ));
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
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(errorMessage),
                ));
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(errorMessage),
                ));
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
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<String?> _uploadProfileImage(File? image) async {
    if (image == null) return null;
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${image.path.split('/').last}');

      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      debugPrint(
          'File uploaded to Firebase Storage. Download URL: $downloadURL');
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.white,
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
            const Text(
              'Register to ScoreBuddy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(
              height: 40,
            ),
            TextField(
              controller: usernameController,
              obscureText: false,
              decoration: const InputDecoration(
                label: Text('Username'),
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple, // Deep Purple border
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple, // Deep Purple focused border
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: emailController,
              obscureText: false,
              decoration: const InputDecoration(
                label: Text('Email'),
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple, // Deep Purple border
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple, // Deep Purple focused border
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('Password'),
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple, // Deep Purple border
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple, // Deep Purple focused border
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('Confirm Password'),
                labelStyle: TextStyle(color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple, // Deep Purple border
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurple, // Deep Purple focused border
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 20.0),
              ),
              child: const Text(
                'Register',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
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
}
