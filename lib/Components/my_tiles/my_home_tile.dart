import 'package:flutter/material.dart';

class MyHomeTile extends StatefulWidget {
  final Icon icon;
  final String tileTitle;
  final String titleSubName;
  const MyHomeTile(
      {super.key,
      required this.icon,
      required this.tileTitle,
      required this.titleSubName});

  @override
  State<MyHomeTile> createState() => _MyHomeTileState();
}

class _MyHomeTileState extends State<MyHomeTile> {
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
