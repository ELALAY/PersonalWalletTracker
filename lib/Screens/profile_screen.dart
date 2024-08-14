import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:personalwallettracker/Components/my_textfields/my_pwdfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';

import '../Models/person_model.dart';
import '../services/auth/auth_service.dart';

class MyProfileScreen extends StatefulWidget {
  final User user;
  final Person personProfile;
  const MyProfileScreen(
      {super.key, required this.user, required this.personProfile});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  AuthService authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  // Text Editing Controllers
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();

  // Loading and Editing State
  bool isLoading = true;
  bool enabledEditkeyInfo = false;

  // Profile Image
  File? _profileImage;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.personProfile.username);
    _emailController = TextEditingController(text: widget.personProfile.email);
    _idController = TextEditingController(text: widget.personProfile.id);
    isLoading = false;
  }

  Future<String?> _uploadProfileImage(File image) async {
    try {
      debugPrint('uploaded prfile image to cloud');
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${image.path.split('/').last}');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      } else {
        debugPrint('No image selected.');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    debugPrint('saving Profile');
    setState(() {
      isLoading = true;
    });
    debugPrint('uploading image');
    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _uploadProfileImage(_profileImage!);
      }
      debugPrint('uploaded image');

      Map<String, dynamic> updatedData = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'id': _idController.text,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      };

      await firebaseDatabasehelper.updatePersonProfile(
          widget.user.uid, updatedData);
      debugPrint('saved profile');
      setState(() {
        isLoading = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
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
            },
          ),
          IconButton(
              onPressed: _changePwdDialog,
              icon: const Icon(Icons.password_outlined))
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Stack(
                      children: [
                        Container(
                          width:
                              120, // Set width to make the CircleAvatar bigger
                          height:
                              120, // Set height to make the CircleAvatar bigger
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : widget.personProfile.profile_picture
                                          .isNotEmpty
                                      ? NetworkImage(
                                          widget.personProfile.profile_picture)
                                      : const NetworkImage(
                                          'https://icons.veryicon.com/png/o/miscellaneous/common-icons-31/default-avatar-2.png',
                                        ) as ImageProvider,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -15,
                          left: -10,
                          child: IconButton(
                              onPressed: _pickProfileImage,
                              icon: const Icon(Icons.add_a_photo_outlined)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    //User ID Field
                    MyTextField(
                      controller: _idController,
                      enabled: false,
                      label: 'User ID',
                      color: Colors.deepPurple,
                    ),
                    //Username Field
                    MyTextField(
                      controller: _usernameController,
                      enabled: enabledEditkeyInfo,
                      label: 'Username',
                      color: Colors.deepPurple,
                    ),
                    //Email Field
                    MyTextField(
                      controller: _emailController,
                      enabled: enabledEditkeyInfo,
                      label: 'Email',
                      color: Colors.deepPurple,
                    ),
                    // //Password Field
                    // MyPwdField(
                    //     controller: _passwordController,
                    //     label: 'Password',
                    //     color: Colors.deepPurple,
                    //     enabled: enabledEditkeyInfo),
                    // const SizedBox(height: 20),
                    enabledEditkeyInfo
                        ? Center(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0, vertical: 20.0),
                              ),
                              child: const Text('save profile'),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
    );
  }

  void _changePwdDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //currenct password
              MyPwdField(
                  controller: _currentPasswordController,
                  label: 'Currenct Password',
                  color: Colors.deepPurple,
                  enabled: true),
              //password field
              MyPwdField(
                  controller: _passwordController,
                  label: 'Password',
                  color: Colors.deepPurple,
                  enabled: true),
              //confirm password
              MyPwdField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  color: Colors.deepPurple,
                  enabled: true),
            ],
          ),
          actions: [
            //cancel chanfe
            TextButton(
              onPressed: () {
                _passwordController.clear();
                _confirmPasswordController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            //change pwd
            TextButton(
              onPressed: () {
                changePassword();
                _passwordController.clear();
                _confirmPasswordController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Change',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  void changePassword() async {
  try {
    if (_currentPasswordController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty) {
      if (_passwordController.text == _confirmPasswordController.text) {
        User? user = FirebaseAuth.instance.currentUser;

        // Re-authenticate the user with their current password
        AuthCredential credential = EmailAuthProvider.credential(
            email: user!.email!, password: _currentPasswordController.text);

        await user.reauthenticateWithCredential(credential);

        // Update the password to the new password
        await user.updatePassword(_passwordController.text);
        debugPrint('Password updated successfully');
        messageDialog('Password updated successfully');
      } else {
        messageDialog("New passwords don't match");
      }
    } else {
      messageDialog('All fields must be filled!');
    }
  } catch (e) {
    if (e is FirebaseAuthException) {
      messageDialog('Error: ${e.message}');
    } else {
      messageDialog('An unexpected error occurred.');
    }
  }
}

  void messageDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            //cancel chanfe
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }
}
