import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final Icon icon;
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
              // boxShadow: [
              //   BoxShadow(
              //       color: Colors.grey.shade400,
              //       blurRadius: 20,
              //       spreadRadius: 2)
              // ]
            ),
          child: widget.icon,
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(widget.action,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,)),
      ],
    );
  }
}
