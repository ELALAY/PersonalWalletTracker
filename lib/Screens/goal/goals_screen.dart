import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:personalwallettracker/Components/goal_box.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/goal_model.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';
import 'edit_goal_screen.dart';
import 'new_goal_screen.dart';

class GoalsOverviewScreen extends StatefulWidget {
  final User user;
  final List<CardModel> myCards;
  const GoalsOverviewScreen(
      {super.key, required this.user, required this.myCards});

  @override
  State<GoalsOverviewScreen> createState() => _GoalsOverviewScreenState();
}

class _GoalsOverviewScreenState extends State<GoalsOverviewScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  List<GoalModel> goals = [];
  String selectedCard = 'All';
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            )
          : LiquidPullToRefresh(
              onRefresh: () async {
                debugPrint('reloading...');
                reload();
                debugPrint('reloaded!');
              },
              backgroundColor: Colors.deepPurple.shade200,
              showChildOpacityTransition: false,
              color: Colors.deepPurple,
              height: 100.0,
              animSpeedFactor: 1,
              child: Column(
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
                          onTapStart: () {
                            showDeleteGoalDialog(goal);
                          },
                          onTapEnd: () {
                            // _showAddAmountDialog(goal);
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditGoalScreen(goal: goal),
                                  ),
                                )
                                .then((value) => reload());
                          },
                          iconTap: () {
                            _showAddAmountDialog(goal);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void navEditGoal(GoalModel goal) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditGoalScreen(goal: goal);
    })).then((value) => reload());
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
        uid: goal.uid,
        goalIcon: goal.goalIcon);
    await firebaseDatabasehelper.updateGoal(updatedGoal);
    CardModel card = await firebaseDatabasehelper.getCardById(selectedCard);
    TransactionModel transaction = TransactionModel(
        cardId: card.id,
        cardName: card.cardName,
        amount: amount,
        category: 'Salary',
        date: DateTime.now(),
        description: 'Saving for ${goal.name}',
        isExpense: true);
    await firebaseDatabasehelper.addTransaction(transaction);
  }

  void showDeleteGoalDialog(GoalModel goal) {
    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text('Deleting Goal!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyButton(
                    label: 'Delete',
                    onTap: () {
                      deleteGoal(goal);
                      Navigator.pop(context);
                    }),
              ],
            ),
          );
        }));
  }

  void deleteGoal(GoalModel goal) async {
    firebaseDatabasehelper.deleteGoal(goal).then((value) => reload());
  }

  void _showAddAmountDialog(GoalModel goal) {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Amount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card Selector
              DropdownButtonFormField<String>(
                value: widget.myCards.any((card) => card.id == selectedCard)
                    ? selectedCard
                    : 'All',
                icon: const Icon(
                  Icons.arrow_downward,
                  color: Colors.deepPurple,
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCard = value;
                      debugPrint(selectedCard);
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Card',
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
                items: [
                  ...widget.myCards.map((card) => DropdownMenuItem<String>(
                        value: card.id,
                        child: Text(card.cardName),
                      )),
                  const DropdownMenuItem<String>(
                    value: 'All',
                    child: Text('All'),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
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
            ],
          ),
          actions: [
            MyButton(
              onTap: () {
                if (amountController.text.isNotEmpty) {
                  final amount = double.parse(amountController.text.trim());
                  addAmount(goal, amount);
                  reload();
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
