import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import '../../Models/transaction_model.dart';
import '../../services/realtime_db/firebase_db.dart';
import '../transaction/edit_transaction_screen.dart';

class CategoryTransactions extends StatefulWidget {
  final String category;
  final CardModel card;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final String user;
  const CategoryTransactions(
      {super.key, required this.category, required this.card, required this.currency,
      required this.startDate, required this.endDate, required this.user});

  @override
  State<CategoryTransactions> createState() => _CategoryTransactionsState();
}

class _CategoryTransactionsState extends State<CategoryTransactions> {
  final FirebaseDB _firebaseDB = FirebaseDB();
  bool _isLoading = true;
  List<TransactionModel> transactions = [];
  //Dates for the filters
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    fetchTransactions();
    _isLoading = false;
  }

  void reload() {
    fetchTransactions();
  }

  void fetchTransactions() async {
    List<TransactionModel> transactionstemp = await _firebaseDB
        .fetchTransactionsByCategoryAndCard(widget.category, widget.card.id);
    // Filter transactions by selected date range
    if (_startDate != null && _endDate != null) {
      transactionstemp = transactionstemp.where((transaction) {
        return transaction.date.isAfter(_startDate!) &&
            transaction.date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }
    setState(() {
      transactions = transactionstemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12)),
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
                                  editTransaction(transaction);
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
                            tileColor: Colors.blueGrey.shade100,
                            title: Text(
                              transaction.description,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                '${formatDate(transaction.date)} - ${transaction.category}'),
                            trailing: Text(
                              '${transaction.isExpense ? '-' : '+'}${transaction.amount.abs().toStringAsFixed(2)} ${widget.currency}',
                              style: TextStyle(
                                  color: transaction.isExpense
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            onTap: () {
                              // Show transaction details
                              _showTransactionDetails(transaction);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  void editTransaction(TransactionModel transaction) async {
    if (widget.category != 'All') {
      CardModel cardTemp = await _firebaseDB.getCardById(transaction.cardId);
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return EditTransactionScreen(
          card: cardTemp,
          transaction: transaction,
          user: widget.user,
        ); // replace with your settings screen
      }));
    } else {
      showInfoSnachBar('Choose a Card!');
    }
  }

  void deleteTransaction(TransactionModel transaction) async {
    bool deleted = await _firebaseDB.deleteTransaction(transaction);
    if (deleted) {
       showSuccessSnachBar('Transaction ${transaction.description} deleted!');      
      reload();
    } else {
      showErrorSnachBar('Error deleting transaction!');
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  void _showTransactionDetails(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(transaction.description),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                // leading: Icon(transaction['categoryIcon']),
                title:
                    Text('Amount: ${transaction.amount.toStringAsFixed(2)} ${widget.currency}'),
                subtitle: Text('Date: ${formatDate(transaction.date)}'),
              ),
              const SizedBox(height: 16.0),
              Text('Account: ${transaction.cardName}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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
}
