import 'package:flutter/material.dart';

class MyListTile extends StatefulWidget {
  final Icon icon;
  final String tileTitle;
  final VoidCallback onTap;

  const MyListTile({
    super.key,
    required this.icon,
    required this.tileTitle,
    required this.onTap,
  });

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ListTile(
        leading: Text(
          widget.tileTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: widget.icon,
        onTap: widget.onTap, // Here the function is being called
      ),
    );
  }
}
