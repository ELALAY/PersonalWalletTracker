import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyPwdField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Color color;
  final bool enabled;
  const MyPwdField(
      {super.key,
      required this.controller,
      required this.label,
      required this.color,
      required this.enabled});

  @override
  State<MyPwdField> createState() => _MyPwdFieldState();
}

class _MyPwdFieldState extends State<MyPwdField> {
  bool obscure = true;

  void toggleObscure() {
    setState(() {
      obscure = !obscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: widget.controller,
        obscureText: obscure,
        enabled: widget.enabled,
        decoration: InputDecoration(
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
          suffixIcon: IconButton(
              onPressed: toggleObscure,
              icon: obscure
                  ? Icon(CupertinoIcons.eye_solid, color: widget.color,)
                  : Icon(CupertinoIcons.eye_slash_fill, color: widget.color,)),
        ),
      ),
    );
  }
}
