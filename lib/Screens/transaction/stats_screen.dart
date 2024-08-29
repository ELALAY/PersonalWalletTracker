import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
import 'package:personalwallettracker/Screens/transaction/category_transactions.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';

import '../../Components/spending_bar_chart.dart';
import '../../Models/category_spending.dart';

// ignore: must_be_immutable
class StatisticsScreen extends StatefulWidget {
  List<CardModel> myCards = [];
  StatisticsScreen({super.key, required this.myCards});

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  final FirebaseDB _firebaseDB = FirebaseDB();
  Map<String, double> _categoryTotals = {};
  bool _isLoading = true;
  List<CategorySpending> _spendingData = [];
  //card choice
  String selectedCard = 'All';
  //Dates for the filters
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<TransactionModel> transactions = [];
      if (selectedCard == 'All') {
        for (CardModel card in widget.myCards) {
          debugPrint('All');
          List<TransactionModel> temp = [];
          temp = await _firebaseDB.fetchTransactionsByCardId(card.id);
          debugPrint(temp.length.toString());
          transactions.addAll(temp);
          debugPrint(transactions.length.toString());
        }
      } else {
        transactions =
            await _firebaseDB.fetchTransactionsByCardId(selectedCard);
      }

      // Filter transactions by selected date range
      if (_startDate != null && _endDate != null) {
        transactions = transactions.where((transaction) {
          return transaction.date.isAfter(_startDate!) &&
              transaction.date.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();
      }

      // Group transactions by category and sum up the amounts
      Map<String, double> totals = {};
      for (var transaction in transactions) {
        if (transaction.isExpense) {
          // Only consider expenses for statistics
          if (totals.containsKey(transaction.category)) {
            totals[transaction.category] =
                totals[transaction.category]! + transaction.amount;
          } else {
            totals[transaction.category] = transaction.amount;
          }
        }
      }

      // Convert map data to list of CategorySpending for the chart
      List<CategorySpending> spendingData = totals.entries
          .map((entry) => CategorySpending(entry.key, entry.value))
          .toList();

      setState(() {
        _categoryTotals = totals;
        _spendingData = spendingData;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading statistics: $e')),
        );
      }
    }
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

      _loadStatistics(); // Fetch transactions again with the new date range
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  void navCategoryTransactions(String category) async {
    if (widget.myCards.isNotEmpty && selectedCard != 'All') {
      CardModel card = await _firebaseDB.getCardById(selectedCard);
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CategoryTransactions(
          card: card,
          category: category,
        ); // replace with your settings screen
      }));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No card selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                //chart
                SizedBox(
                  height: 200.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _categoryTotals.isEmpty
                            ? const Center(
                                child: Text('No transactions available'),
                              )
                            : Expanded(
                                child: SpendingBarChart(data: _spendingData),
                              ),
                      ],
                    ),
                  ),
                ),
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
                          _loadStatistics();
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
                  padding: const EdgeInsets.symmetric(horizontal:16.0),
                  child: Row(
                    children: [
                      Text(_startDate != null
                          ? formatDate(_startDate!)
                          : ''),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Text(_endDate != null ? formatDate(_endDate!) : '')
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Spending by Category',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
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
                        const SizedBox(height: 16.0),
                        Expanded(
                          child: _categoryTotals.isEmpty
                              ? const Center(
                                  child: Text('No transactions available'),
                                )
                              : ListView.builder(
                                  itemCount: _categoryTotals.length,
                                  itemBuilder: (context, index) {
                                    String category =
                                        _categoryTotals.keys.elementAt(index);
                                    double total = _categoryTotals[category]!;
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        leading: SizedBox(
                                  height: 35.0,
                                  child: categoryIcon(category)),
                                        title: Text(category),
                                        tileColor: Colors.blueGrey[100],
                                        trailing: Text(
                                            '\$${total.toStringAsFixed(2)}'),
                                        onTap: () {
                                          navCategoryTransactions(category);
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Image categoryIcon(String name) {
    try {
      return Image.asset(
        'lib/Images/${name.toLowerCase()}.png',
      );
    } catch (e) {
      throw Exception('Firebase error: $e');
    }
  }
}
