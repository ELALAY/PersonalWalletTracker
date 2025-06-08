import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/category_model.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
import 'package:personalwallettracker/Screens/transaction/edit_transaction_screen.dart';
import 'package:personalwallettracker/Utils/globals.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';
import 'package:personalwallettracker/services/notifications/notification.dart';

import 'new_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String currency;
  final CardModel card;
  final List<CardModel> myCards;
  final String user;
  const TransactionHistoryScreen({
    super.key,
    required this.card,
    required this.myCards,
    required this.currency,
    required this.user,
  });

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
  Map<String, CategoryModel> categories = {};

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  List<TransactionModel> _sortTransactions(
    List<TransactionModel> transactions,
  ) {
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
      debugPrint(selectedCard);
      transactionstemp = await firebaseDB.fetchTransactionsByCardId(
        selectedCard,
      );
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

    Map<String, CategoryModel> catsMap = {};
    List<CategoryModel> catslist = await firebaseDB.getCategories(widget.user);

    for (CategoryModel c in catslist) {
      catsMap[c.name] = c;
    }
    debugPrint(catsMap.length.toString());

    if (mounted) {
      setState(() {
        transactions = transactionstemp;
        totalIncome = totalIncometemp;
        totalExpenses = totalExpensestemp;
        isLoading = false;
        categories = catsMap;
      });
    }
  }

  @override
  void initState() {
    selectedCard = widget.card.id;
    _startDate = getStartOfMonth();
    _endDate = getEndOfMonth();
    fetchAllTransactions();
    isLoading = false;
    super.initState();
  }

  // Get the start of the current month
  DateTime getStartOfMonth() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, 1); // First day of the current month
  }

  // Get the end of the current month
  DateTime getEndOfMonth() {
    DateTime now = DateTime.now();
    return DateTime(
      now.year,
      now.month + 1,
      0,
    ); // Last day of the current month
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
                      Icon(Icons.arrow_upward),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Newsest',
                  child: Row(
                    children: [
                      Text('Sort by Newsest'),
                      Icon(Icons.arrow_downward),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                  // Card Selector
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      value:
                          widget.myCards.any((card) => card.id == selectedCard)
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
                        ...widget.myCards.map(
                          (card) => DropdownMenuItem<String>(
                            value: card.id,
                            child: Text(card.cardName),
                          ),
                        ),
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
                        //dates
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Date Range',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _startDate != null
                                      ? formatDate(_startDate!)
                                      : '',
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  _endDate != null ? formatDate(_endDate!) : '',
                                ),
                              ],
                            ),
                          ],
                        ),
                        //select date range
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Income: ${totalIncome.toStringAsFixed(2)} ${widget.currency}',
                                  style: const TextStyle(color: Colors.green),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Total Expenses: ${totalExpenses.toStringAsFixed(2)} ${widget.currency}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            Text(
                              'Net Balance: ${(totalIncome - totalExpenses).toStringAsFixed(2)} ${widget.currency}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          '* isRecurring transaction',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Transaction List
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        // return MyTransactionTile(transaction: transaction);
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    192,
                                    174,
                                    174,
                                  ),
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                ),
                              ],
                            ),
                            child: ListTile(
                              tileColor: Colors.grey.shade300,
                              title: Text(
                                "${transaction.description} ${transaction.isRecurring ? '*' : ''}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${formatDate(transaction.date)} - ${transaction.category}',
                              ),
                              leading: SizedBox(
                                height: 35.0,
                                child: categoryIcon(
                                  categories[transaction.category]?.iconName ??
                                      'other',
                                ),
                              ),
                              trailing: Text(
                                '${transaction.isExpense ? '-' : '+'} ${transaction.amount.abs().toStringAsFixed(2)} ${widget.currency}',
                                style: TextStyle(
                                  color: transaction.isExpense
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
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
      lastDate: DateTime(2100),
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
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ), // Background color of the dialog
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return EditTransactionScreen(
              card: cardTemp,
              transaction: transaction,
              user: widget.user,
            ); // replace with your settings screen
          },
        ),
      ).then((value) => reload());
    } else {
      showInfoSnachBar('Choose a Card!');
    }
  }

  void deleteTransaction(TransactionModel transaction) async {
    bool deleted = await firebaseDB.deleteTransaction(transaction);
    if (deleted) {
      showSuccessSnachBar('Transaction deleted Sucessfully!');
      LocalNotificationService().showNotification(
        title: 'Delete Transaction - ${transaction.cardName}',
        body: '${transaction.amount} -> ${transaction.cardName}',
      );
      reload();
    } else {
      showErrorSnachBar('Error deleting Transaction!');
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
                title: Text(
                  'Amount: ${transaction.amount.toStringAsFixed(2)} ${widget.currency}',
                ),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AddTransactionScreen(
              card: cardTemp,
              user: widget.user,
            ); // replace with your settings screen
          },
        ),
      ).then((value) => reload());
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No card selected')));
    }
  }

  void showErrorSnachBar(String message) {
    awesomeTopSnackbar(
      context,
      message,
      iconWithDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.amber.shade400,
      ),
      backgroundColor: Colors.amber,
      icon: const Icon(Icons.close, color: Colors.white),
    );
  }

  void showInfoSnachBar(String message) {
    awesomeTopSnackbar(
      context,
      message,
      iconWithDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.lightBlueAccent.shade400,
      ),
      backgroundColor: Colors.lightBlueAccent,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  void showSuccessSnachBar(String message) {
    awesomeTopSnackbar(
      context,
      message,
      iconWithDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.green.shade400,
      ),
      backgroundColor: Colors.green,
      icon: const Icon(Icons.check, color: Colors.white),
    );
  }
}
