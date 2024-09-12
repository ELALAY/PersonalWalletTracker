import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  const OnboardingPage(
      {super.key,
      required this.title,
      required this.description,
      required this.image});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            Center(
              child: SizedBox(
                  height: 300,
                  child: Image.asset('lib/Images/${widget.image}.gif')),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ]);
  }
}
