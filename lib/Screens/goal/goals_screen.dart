import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Components/goal_box.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';
import '../../Models/goal_model.dart';
import 'new_goal_screen.dart';

class GoalsOverviewScreen extends StatefulWidget {
  final User user;
  const GoalsOverviewScreen({super.key, required this.user});

  @override
  State<GoalsOverviewScreen> createState() => _GoalsOverviewScreenState();
}

class _GoalsOverviewScreenState extends State<GoalsOverviewScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  List<GoalModel> goals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGoals();
    isLoading = false;
  }

  void reload() {
    isLoading = true;
    debugPrint('reloading...');
    fetchGoals();
    isLoading = false;
  }

  void fetchGoals() async {
    try {
      List<GoalModel> temp = await firebaseDatabasehelper.getGoals(widget.user);
      setState(() {
        goals = temp;
      });
    } catch (e) {
      debugPrint('no user and no goals found! $e');
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
        actions: [
          IconButton(onPressed: navNewGoalScreen, icon: const Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 16.0,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return MyGoalBox(
                  goal: goal,
                  onTap: () {
                    _showAddAmountDialog(goal);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void navNewGoalScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NewGoalScreen(
          user: widget.user); // replace with your settings screen
    })).then((value) => reload());
  }

  void addAmount(GoalModel goal, double amount) async {
    GoalModel updatedGoal = GoalModel.withId(
        id: goal.id,
        name: goal.name,
        currentAmount: goal.currentAmount + amount,
        targetAmount: goal.targetAmount,
        endDate: goal.endDate,
        uid: goal.uid);
    await firebaseDatabasehelper.updateGoal(updatedGoal);
  }

  void _showAddAmountDialog(GoalModel goal) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Amount'),
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.deepPurple),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.deepPurple, // Deep Purple border
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.deepPurple, // Deep Purple focused border
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.deepPurple),),
            ),
            MyButton(
              onTap: () {
                if (amountController.text.isNotEmpty) {
                  final amount = double.parse(amountController.text.trim());
                  addAmount(goal, amount);
                  Navigator.of(context).pop();
                }
              },
              label: 'Add',
            ),
          ],
        );
      },
    ).then((value) => reload());
  }
}
