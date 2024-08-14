import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/services/auth/register_screen.dart';
import '../../Screens/home.dart';
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Error'),
            content: const Text('Invalid Credentials'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Input Error'),
          content: const Text('Both fields should be filled!'),
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
            const Icon(
              Icons.lock_open_rounded,
              size: 100,
              color: Colors.deepPurple,
            ),
            const Text(
              'Login to Personal Wallet Tracker',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed:
                    login, // Disable button if card or category is not selected
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 20.0),
                ),
                child: const Text('Add Transaction'),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
