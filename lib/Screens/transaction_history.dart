import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
import 'package:personalwallettracker/Utils/firebase_db.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

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

  // Sample summary data
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  //Dates for the filters
  DateTime? _startDate;
  DateTime? _endDate;

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  void fetchTransactions() async {
    List<TransactionModel> transactionstemp =
        await firebaseDB.fetchTransactions();
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
    transactionstemp.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      transactions = transactionstemp;
      totalIncome = totalIncometemp;
      totalExpenses = totalExpensestemp;
    });
  }

  @override
  void initState() {
    fetchTransactions();
    super.initState();
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                        Text(
                            _startDate != null ? formatDate(_startDate!) : ''),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Text(_endDate != null ? formatDate(_endDate!) : '')
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
                    Text('Total Income: \$${totalIncome.toStringAsFixed(2)}',
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
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
                            // toggleGroupStatus(group);
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
                      subtitle: Text(formatDate(transaction.date)),
                      trailing: Text(
                        '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                            color:
                                transaction.isExpense ? Colors.red : Colors.green,
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

      fetchTransactions(); // Fetch transactions again with the new date range
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
}
