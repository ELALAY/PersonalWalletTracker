import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/recurring_transaction_model.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
import 'package:personalwallettracker/Screens/transaction/recurring_transactions/new_recurring_transaction_screen.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';

import '../../../Models/person_model.dart';
import '../../../Utils/globals.dart';
import 'edit_recurring_transaction_screen.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  final List<CardModel> myCards;
  final String user;
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
  CardModel? selectedCard;

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
        await firebaseDB.fetchUserRecurringTransactions(widget.user);
    debugPrint(transactionstemp.length.toString());

    // Sort transactions from newest to oldest
    transactionstemp = _sortTransactions(transactionstemp);

    setState(() {
      transactions = transactionstemp;
    });
  }

  void showUncreatedRecurringTransactions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepOrange,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (transactions.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.deepOrange.shade200,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                        leading: const Text(
                          'Check Recurring Transactions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15),
                        ),
                        trailing: const Icon(
                          Icons.history,
                          color: Colors.white,
                        ),
                        onTap: () {}),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
              child: ListView.builder(
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
                        tileColor: transaction.isArchived
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
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
                            '${formatDate(transaction.date)} - ${transaction.category}'),
                        leading: SizedBox(
                            height: 35.0,
                            child: categoryIcon(transaction.category)),
                        trailing: IconButton(
                          icon: transaction.isArchived
                              ? const Icon(Icons.unarchive_rounded,
                                  color: Colors.deepPurple)
                              : const Icon(Icons.add_outlined,
                                  color: Colors.deepPurple),
                          onPressed: () {
                            if (transaction.isArchived) {
                              unarchiveRecurringTransaction(transaction);
                            } else {
                              addRecurringTransactionDialog(transaction);
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
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

  void unarchiveRecurringTransaction(
      RecurringTransactionModel transaction) async {
    RecurringTransactionModel rec = RecurringTransactionModel.withId(
        id: transaction.id,
        ownerId: transaction.ownerId,
        amount: transaction.amount,
        category: transaction.category,
        date: transaction.date,
        description: transaction.description,
        isExpense: transaction.isExpense,
        isArchived: false,
        recurrenceType: transaction.recurrenceType);

    await firebaseDB.updateRecurringTransaction(rec);

    showSuccessSnachBar('Recurring Transaction unarchived Sucessfully!');
    reload();
  }

  void addRecurringTransaction(RecurringTransactionModel transaction) async {
    try {
      bool isCreated = false;
      if (selectedCard != null) {
        // Create new transaction
        TransactionModel newTransaction = TransactionModel(
            cardId: selectedCard!.id,
            cardName: selectedCard!.cardName,
            amount: transaction.amount,
            category: transaction.category,
            date: DateTime.now(),
            description: transaction.description,
            isExpense: transaction.isExpense,
            isRecurring: true);
        // Add transaction
        isCreated = await firebaseDB.addTransaction(newTransaction);

        if (isCreated) {
          debugPrint(transaction.amount.toString());
          // isEpense ? negative amount : positive amount
          double amount =
              transaction.isExpense ? -transaction.amount : transaction.amount;

          // since isCreated=true => update card balance
          firebaseDB.updateCardBalance(
              selectedCard!.id, selectedCard!.balance + amount);
          debugPrint('updated card balance!');

          // update recurring transaction for next date in another month
          RecurringTransactionModel newRec = RecurringTransactionModel.withId(
              id: transaction.id,
              ownerId: transaction.ownerId,
              amount: transaction.amount,
              category: transaction.category,
              date:
                  updateNextDate(transaction.date, transaction.recurrenceType),
              description: transaction.description,
              isExpense: transaction.isExpense,
              recurrenceType: transaction.recurrenceType);
          await firebaseDB.updateRecurringTransaction(newRec);

          // then reload the recurring transactions
          reload();

          showSuccessSnachBar('Transaction Created Successfully!');
        } else {
          showErrorSnachBar('Error Creating Transaction!');
        }
      } else {
        showInfoSnachBar("Couldn't load card! please try again ...");
      }
    } catch (e) {
      showErrorSnachBar('Error Creating Transaction!');
      debugPrint('Error Creating Transaction');
    }
  }

  DateTime updateNextDate(DateTime date, int recurrenceType) {
    if (recurrenceType == 0) {
      return DateTime(
        date.year,
        date.month + 1, // Add 1 month to the current month
        date.day,
      );
    } else if (recurrenceType == 1) {
      return DateTime(
        date.year,
        date.month,
        date.day + 8, // Add 1 week to the current month
      );
    } else {
      return DateTime(
        date.year,
        date.month,
        date.day + 15, // Add two weeks to the current month
      );
    }
  }

  void addRecurringTransactionDialog(RecurringTransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Card for: ${transaction.description}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card Selector
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<CardModel>(
                  icon: const Icon(
                    Icons.arrow_downward,
                    color: Colors.deepPurple,
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCard = value;
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
                    ...widget.myCards.map((card) => DropdownMenuItem<CardModel>(
                          value: card,
                          child: Text(card.cardName),
                        )),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            TextButton(
              onPressed: () {
                addRecurringTransaction(transaction);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  void editRecurringTransaction(RecurringTransactionModel transaction) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditReccuringTransactionScreen(
        transaction: transaction,
        user: widget.user,
        personProfile: widget.personProfile,
        myCards: widget.myCards,
      );
    })).then((value) => reload());
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
