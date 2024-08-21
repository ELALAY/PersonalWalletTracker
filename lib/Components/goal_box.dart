import 'package:flutter/material.dart';

class MyGoalBox extends StatefulWidget {
  const MyGoalBox({super.key});

  @override
  State<MyGoalBox> createState() => _MyGoalBoxState();
}

class _MyGoalBoxState extends State<MyGoalBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      height: 100.0,
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target: \$100'),
            Text('End Date: 22/12/2024'),
            LinearProgressIndicator(
              value: 0.45,
              backgroundColor: Colors.grey[300],
              color: Colors.black,
            ),
            Text('45% reached'),
          ],
        ),
      ),
    );
  }
}
