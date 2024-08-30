import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Models/goal_model.dart';
import 'package:personalwallettracker/Screens/goal/edit_goal_screen.dart';

class MyGoalBox extends StatefulWidget {
  final GoalModel goal;
  final VoidCallback onTapEnd;
  final VoidCallback onTapStart;

  const MyGoalBox({
    super.key,
    required this.goal,
    required this.onTapStart,
    required this.onTapEnd,
  });

  @override
  State<MyGoalBox> createState() => _MyGoalBoxState();
}

class _MyGoalBoxState extends State<MyGoalBox> {
  double progress = 0.0;

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  Image categoryIcon(String name) {
    try {
      return Image.asset(
        'lib/Images/${name.toLowerCase()}.png',
      );
    } catch (e) {
      throw Exception('Firebase error: $e');
    }
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
      child: Slidable(
        key: const ValueKey(0),

        // The start action pane is the one at the left or the top side.
        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const StretchMotion(),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              borderRadius: BorderRadius.circular(12.0),
              onPressed: (context) {
                widget.onTapStart();  // Corrected: Add the function call
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete_forever_outlined,
              label: 'Delete',
            ),
          ],
        ),

        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const StretchMotion(),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              borderRadius: BorderRadius.circular(12.0),
              onPressed: (context) {
                widget.onTapEnd();  // Corrected: Add the function call
              },
              backgroundColor: const Color.fromARGB(255, 192, 174, 174),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
          ],
        ),
        child: Container(
          width: 400.0,
          height: 180.0,
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
                Center(
                  child: Column(
                    children: [
                      Stack(alignment: AlignmentDirectional.center, children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        Container(
                          height: 40,
                          width: 45,
                          decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(40)),
                        ),
                        SizedBox(
                            height: 35.0,
                            width: 35,
                            child: categoryIcon(widget.goal.goalIcon)),
                      ]),
                      Text(
                        widget.goal.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
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
      ),
    );
  }
}
