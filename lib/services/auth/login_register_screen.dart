import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Components/my_textfields/my_emailfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_pwdfield.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/Screens/home.dart';
import 'package:personalwallettracker/Screens/onboarding/onboarding_screen.dart';
import 'package:personalwallettracker/services/auth/register_screen.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';
import '../../Utils/globals.dart';
import 'auth_service.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  void navRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const RegisterScreen();
    }));
  }

  void login() async {
    if (emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty) {
      try {
        await authService.signInWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
        showInfoSnachBar(errorMessage);
      } catch (e) {
        showInfoSnachBar('Invalid Credentials, try again!');
      }
    } else {
      showInfoSnachBar('Both fields should be filled!');
    }
  }

  void loginGoogle() async {
    try {
      showDialog(
        context: context,
        // barrierDismissible:
        //     false, // Prevents dismissing the dialog by tapping outside
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
          );
        },
      );
      authService.signInwithGoogle();
      User? user = authService.getCurrentUser();

      if (user != null) {
        Person? profile = await FirebaseDB().getPersonProfile(user.uid);
        if (profile == null) {
          showInfoSnachBar('Creating Profile!');
          // if no profile => create a new profile
          Person personProfile = Person.fromMap({
            'username': user.displayName,
            'email': user.email,
            'profile_picture': user.photoURL,
          }, user.uid);
          await FirebaseFirestore.instance
              .collection('persons')
              .doc(user.uid)
              .set(personProfile.toMap());
        } else {
          showSuccessSnachBar('Logged in Successfully!');
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      } else {
        return;
      }
    } catch (e) {
      debugPrint('error google sing in');
      showInfoSnachBar('Error Signing in with Google, try again!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: darkTheme ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            SizedBox(height: 150, child: Image.asset('lib/Images/login.gif')),
            // const Icon(
            //   Icons.lock_open_rounded,
            //   size: 100,
            //   color: Colors.deepPurple,
            // ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Personal Wallet Tracker',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(height: 40),
            //Email Field
            MyEmailField(
                controller: emailController,
                label: 'Email',
                color: Colors.deepPurple,
                enabled: true),
            const SizedBox(height: 10),
            //Password Field
            MyPwdField(
                controller: passwordController,
                label: 'Password',
                color: Colors.deepPurple,
                enabled: true),
            const SizedBox(height: 20),
            MyButton(label: 'Log In', onTap: login),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: navRegister,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not a member?'),
                  SizedBox(width: 5),
                  Text(
                    'Register Now!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: loginGoogle,
              child: Container(
                height: 100.0,
                width: 100.0,
                // padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurple, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset.fromDirection(1, 2),
                        blurRadius: 2.0)
                  ],
                ),
                child: Image.asset(
                  'lib/Images/google_icon.png',
                  // color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
