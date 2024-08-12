import 'package:flutter/material.dart';

class MyListTile extends StatefulWidget {
  final Icon icon;
  final String tileTitle;
  final String titleSubName;
  const MyListTile(
      {super.key,
      required this.icon,
      required this.tileTitle,
      required this.titleSubName});

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      
      children: [
        Container(
          height: 80.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: widget.icon,
        ),
        const SizedBox(
          width: 30.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.tileTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Text(
              widget.titleSubName,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const Icon(Icons.arrow_forward_ios),
        
      ],
    );
  }
}
