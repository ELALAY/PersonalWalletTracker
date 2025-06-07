import 'package:flutter/material.dart';

class MyNumberField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Color color;
  final bool enabled;
  const MyNumberField({super.key, required this.controller, required this.label, required this.color, required this.enabled});

  @override
  State<MyNumberField> createState() => _MyNumberFieldState();
}

class _MyNumberFieldState extends State<MyNumberField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        enabled: widget.enabled,
        decoration:  InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: widget.color),
          ),
          labelText: widget.label,
          labelStyle: TextStyle(color: widget.color),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.color),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.color),
          ),
        ),
      ),
    );
  }
}
