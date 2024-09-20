import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/recurring_transaction_model.dart';
import 'package:personalwallettracker/Screens/transaction/recurring_transactions/new_recurring_transaction_screen.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';

import '../../../Models/person_model.dart';
import '../../../Utils/globals.dart';
import 'edit_recurring_transaction_screen.dart';

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
  FirebaseDB firebaseDB = FirebaseDB();

  bool isLoading = true;
  bool isSortedByNewest = true;
  List<RecurringTransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchAllTransactions();
    isLoading = false;
  }

  void reload() {
    isLoading = true;
    fetchAllTransactions();
    isLoading = false;
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  List<RecurringTransactionModel> _sortTransactions(
      List<RecurringTransactionModel> transactions) {
    if (isSortedByNewest) {
      // Sort by date
      transactions.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    } else {
      // Sort by category name
      transactions.sort((a, b) => a.date.compareTo(b.date));
    }
    return transactions;
  }

  void fetchAllTransactions() async {
    List<RecurringTransactionModel> transactionstemp =
        await firebaseDB.fetchUserRecurringTransactions(widget.user.uid);
    debugPrint(transactionstemp.length.toString());

    // Sort transactions from newest to oldest
    transactionstemp = _sortTransactions(transactionstemp);

    setState(() {
      transactions = transactionstemp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                // return MyTransactionTile(transaction: transaction);
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
                          onPressed: (context) {
                            deleteTransaction(transaction);
                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_forever_outlined,
                          label: 'Delete',
                        ),
                      ],
                    ),

                    // The start action pane is the one at the left or the top side.
                    endActionPane: ActionPane(
                      // A motion is a widget used to control how the pane animates.
                      motion: const StretchMotion(),

                      // All actions are defined in the children parameter.
                      children: [
                        // A SlidableAction can have an icon and/or a label.
                        SlidableAction(
                          onPressed: (context) {
                            editRecurringTransaction(transaction);
                          },
                          backgroundColor:
                              const Color.fromARGB(255, 192, 174, 174),
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: ListTile(
                      tileColor: Colors.grey.shade300,
                      title: Row(
                        children: [
                          Text(
                            transaction.description,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '    ${transaction.isExpense ? '-' : '+'} ${transaction.amount.abs().toStringAsFixed(2)} ${widget.personProfile.default_currency}',
                            style: TextStyle(
                                color: transaction.isExpense
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      subtitle: Text(
                          '${transaction.date.day} of the month - ${transaction.category}'),
                      leading: SizedBox(
                          height: 35.0,
                          child: categoryIcon(transaction.category)),
                      trailing: const Icon(
                        Icons.add_outlined,
                        color: Colors.deepPurple,
                      ),
                      onTap: () {},
                    ),
                  ),
                );
              },
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

  // void editTransaction(RecurringTransactionModel transaction) async {
  //     // ignore: use_build_context_synchronously
  //     Navigator.push(context, MaterialPageRoute(builder: (context) {
  //       return EditRecurringTransactionScreen(
  //         myCards: widget.myCards,
  //         transaction: transaction,
  //         user: widget.user,
  //         personProfile: widget.personProfile,
  //       ); // replace with your settings screen
  //     })).then((value) => reload());
  // }

  void editRecurringTransaction(RecurringTransactionModel transaction) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditReccuringTransactionScreen(
        transaction: transaction,
        user: widget.user,
        personProfile: widget.personProfile,
        myCards: widget.myCards,
      );
    }));
  }

  void deleteTransaction(RecurringTransactionModel transaction) async {
    bool deleted = await firebaseDB.deleteRecurringTransaction(transaction);
    if (deleted) {
      showSuccessSnachBar('Recurring Transaction deleted Sucessfully!');
      reload();
    } else {
      showErrorSnachBar('Error deleting Recurring Transaction!');
    }
  }

  void showErrorSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.amber.shade400),
        backgroundColor: Colors.amber,
        icon: const Icon(
          Icons.close,
          color: Colors.white,
        ));
  }

  void showInfoSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.lightBlueAccent.shade400),
        backgroundColor: Colors.lightBlueAccent,
        icon: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ));
  }

  void showSuccessSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.green.shade400),
        backgroundColor: Colors.green,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ));
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
