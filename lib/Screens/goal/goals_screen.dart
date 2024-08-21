import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Components/goal_box.dart';
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
      debugPrint('no user and no goals found!');
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
          IconButton(onPressed: navNewGoalScreen, icon: Icon(Icons.add))
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
                final progress = (goal.currentAmount / goal.targetAmount) * 100;

                return MyGoalBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navNewGoalScreen,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  void navNewGoalScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NewGoalScreen(
          user: widget.user); // replace with your settings screen
    })).then((value) => reload());
  }
}
