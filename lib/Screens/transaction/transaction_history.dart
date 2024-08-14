import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
import 'package:personalwallettracker/Screens/transaction/edit_transaction_screen.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';

import '../../Models/card_model.dart';
import 'new_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final CardModel card;
  final List<CardModel> myCards;
  const TransactionHistoryScreen(
      {super.key, required this.card, required this.myCards});

  @override
  TransactionHistoryScreenState createState() =>
      TransactionHistoryScreenState();
}

class TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  FirebaseDB firebaseDB = FirebaseDB();
  // Sample data for transactions
  List<TransactionModel> transactions = [];
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endtDateController = TextEditingController();
  //card choice
  String selectedCard = 'All';
  //fetched cards
  // Sample summary data
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  //Dates for the filters
  DateTime? _startDate;
  DateTime? _endDate;
  //loading indicator
  bool isLoading = true;
  //sorting choice: true => date, false => category
  bool _isSortedByNewest = true; // Default sorting by date

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  List<TransactionModel> _sortTransactions(
      List<TransactionModel> transactions) {
    if (_isSortedByNewest) {
      // Sort by date
      transactions.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    } else {
      // Sort by category name
      transactions.sort((a, b) => a.date.compareTo(b.date));
    }
    return transactions;
  }

  void fetchAllTransactions() async {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    List<TransactionModel> transactionstemp = [];
    if (selectedCard == 'All') {
      for (CardModel card in widget.myCards) {
        debugPrint('All');
        List<TransactionModel> temp = [];
        temp = await firebaseDB.fetchTransactionsByCardId(card.id);
        debugPrint(temp.length.toString());
        transactionstemp.addAll(temp);
        debugPrint(transactionstemp.length.toString());
      }
    } else {
      debugPrint('All');
      transactionstemp =
          await firebaseDB.fetchTransactionsByCardId(selectedCard);
      debugPrint(transactionstemp.length.toString());
    }
    double totalIncometemp = 0.0;
    double totalExpensestemp = 0.0;

    // Filter transactions by selected date range
    if (_startDate != null && _endDate != null) {
      transactionstemp = transactionstemp.where((transaction) {
        return transaction.date.isAfter(_startDate!) &&
            transaction.date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    for (TransactionModel transaction in transactionstemp) {
      if (transaction.isExpense) {
        totalExpensestemp += transaction.amount;
      } else {
        totalIncometemp += transaction.amount;
      }
    }
    // Sort transactions from newest to oldest
    transactionstemp = _sortTransactions(transactionstemp);

    if (mounted) {
      setState(() {
        transactions = transactionstemp;
        totalIncome = totalIncometemp;
        totalExpenses = totalExpensestemp;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    selectedCard = widget.card.id;
    fetchAllTransactions();
    isLoading = false;
    super.initState();
  }

  void reload() async {
    isLoading = true;
    fetchAllTransactions();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
        title: const Text('Transaction History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _isSortedByNewest = value == 'Newsest';
              });
              _sortTransactions(transactions);
            },
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Oldest',
                  child: Row(
                    children: [
                      Text('Sort by Oldest'),
                      Icon(Icons.arrow_upward)
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Newsest',
                  child: Row(
                    children: [
                      Text('Sort by Newsest'),
                      Icon(Icons.arrow_downward)
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Card Selector
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
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
                          fetchAllTransactions();
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
                          color:
                              Colors.deepPurple, // Deep Purple focused border
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
                ),
                // Date Range Selector (Placeholder)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Date Range',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              // TextField(
                              //   controller: startDateController,
                              //   ),
                              Text(_startDate != null
                                  ? formatDate(_startDate!)
                                  : ''),
                              const SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                  _endDate != null ? formatDate(_endDate!) : '')
                            ],
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          _selectDateRange(context);
                        },
                        icon: const Icon(
                          Icons.calendar_month,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                // Summary Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Total Income: \$${totalIncome.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green)),
                          const SizedBox(height: 4.0),
                          Text(
                              'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                      Text(
                          'Net Balance: \$${(totalIncome - totalExpenses).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // Transaction List
                Expanded(
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
                            // leading: IconButton(
                            //     onPressed: () {
                            //       editTransaction(transaction);
                            //     },
                            //     icon: const Icon(Icons.edit)),
                            trailing: Text(
                              '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.abs().toStringAsFixed(2)}',
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
      floatingActionButton: FloatingActionButton(
        onPressed: navNewTransaction,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.deepPurple, // Body text color
            ),
            dialogBackgroundColor:
                Colors.white, // Background color of the dialog
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      fetchAllTransactions(); // Fetch transactions again with the new date range
    }
  }

  void editTransaction(TransactionModel transaction) async {
    if (selectedCard.isNotEmpty && selectedCard != 'All') {
      CardModel cardTemp = await firebaseDB.getCardById(selectedCard);
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return EditTransactionScreen(
          card: cardTemp,
          transaction: transaction,
        ); // replace with your settings screen
      }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error moving')),
      );
    }
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
                    Text('Amount: \$${transaction.amount.toStringAsFixed(2)}'),
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

  void navNewTransaction() async {
    if (selectedCard.isNotEmpty && selectedCard != 'All') {
      CardModel cardTemp = await firebaseDB.getCardById(selectedCard);
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddTransactionScreen(
          card: cardTemp,
        ); // replace with your settings screen
      })).then((value) => reload());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No card selected')),
      );
    }
  }
}
