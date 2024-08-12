import 'package:flutter/material.dart';
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

  // Sample summary data
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  //Dates for the filters
  DateTime? _startDate;
  DateTime? _endDate;

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

    setState(() {
      transactions = transactionstemp;
      totalIncome = totalIncometemp;
      totalExpenses = totalExpensestemp;
    });
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
                const Text(
                  'Date Range',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    _selectDateRange(context);
                  },
                  child: const Text('Select Date Range'),
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
                return ListTile(
                  title: Text(transaction.description),
                  subtitle: Text(transaction.date.toString()),
                  trailing: Text(
                    '${transaction.isExpense ? '-' : '+'}\$${transaction.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction.isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    // Show transaction details
                    _showTransactionDetails(transaction);
                  },
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
                subtitle: Text('Date: ${transaction.date}'),
              ),
              const SizedBox(height: 16.0),
              Text('Account: ${transaction.cardId}'),
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
