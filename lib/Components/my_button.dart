import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String icon;
  final String action;
  const MyButton({super.key, required this.icon, required this.action});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100.0,
          width: 150.0,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.pink,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            'lib/Images/${widget.icon}.png',
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(widget.action,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            )),
      ],
    );
  }
}
