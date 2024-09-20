import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Screens/transaction/new_recurring_transaction_screen.dart';

import '../../Models/person_model.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  final List<CardModel> myCards;
  final User user;
  final Person personProfile;
  const RecurringTransactionsScreen(
      {super.key,
      required this.user,
      required this.personProfile,
      required this.myCards});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: navNewRecurringTransactionScreen,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  void navNewRecurringTransactionScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddRecurringTransactionScreen(
        user: widget.user,
        personProfile: widget.personProfile,
        myCards: widget.myCards,
      );
    }));
  }
}
