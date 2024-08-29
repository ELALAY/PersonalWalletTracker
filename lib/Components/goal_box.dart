import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Models/goal_model.dart';

class MyGoalBox extends StatefulWidget {
  final GoalModel goal;
  final Function onTap;

  const MyGoalBox({super.key, required this.goal, required this.onTap});

  @override
  State<MyGoalBox> createState() => _MyGoalBoxState();
}

class _MyGoalBoxState extends State<MyGoalBox> {
  double progress = 0.0;

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  void initState() {
    super.initState();
    progress = widget.goal.currentAmount / widget.goal.targetAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 300.0,
        height: 150.0,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.goal.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  IconButton(
                      onPressed: () {
                        widget.onTap(); // Call the onTap function
                      },
                      icon: const Icon(Icons.add, color: Colors.white))
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Text(widget.goal.currentAmount.toStringAsFixed(2),
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                  Text(' / ${widget.goal.targetAmount}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${(progress * 100).toStringAsFixed(2)}% reached',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(
                    'End Date: ${formatDate(widget.goal.endDate)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
