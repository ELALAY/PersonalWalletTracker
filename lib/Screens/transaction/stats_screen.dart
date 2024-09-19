import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
import 'package:personalwallettracker/Screens/categories/category_transactions.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';

import '../../Components/spending_bar_chart.dart';
import '../../Models/category_spending.dart';

// ignore: must_be_immutable
class StatisticsScreen extends StatefulWidget {
  final String currency;
  List<CardModel> myCards = [];
  StatisticsScreen({super.key, required this.myCards, required this.currency});

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
    _startDate = getStartOfMonth();
    _endDate = getEndOfMonth();
    _loadStatistics();
    _isLoading = false;
  }

  void reload() async {
    _startDate = getStartOfMonth();
    _endDate = getEndOfMonth();
    _loadStatistics();
    _isLoading = false;
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
        now.year, now.month + 1, 0); // Last day of the current month
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
      });
    } catch (e) {
      if (mounted) {
        showErrorSnachBar('Error loading Stats!');
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

  void navCategoryTransactions(String category) async {
    if (widget.myCards.isNotEmpty && selectedCard != 'All') {
      CardModel card = await _firebaseDB.getCardById(selectedCard);
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CategoryTransactions(
          card: card,
          category: category,
          currency: widget.currency,
        ); // replace with your settings screen
      }));
    } else {
      showInfoSnachBar('Choose a Card!');
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
                        ...widget.myCards
                            .map((card) => DropdownMenuItem<String>(
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
                          // Date Range Selector (Placeholder)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date Range:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Text(_startDate != null
                                        ? formatDate(_startDate!)
                                        : ''),
                                    const SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(_endDate != null
                                        ? formatDate(_endDate!)
                                        : '')
                                  ],
                                ),
                              ],
                            ),
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
                                          title: Text(category),
                                          tileColor: Colors.blueGrey[100],
                                          trailing: Text(
                                              '${total.toStringAsFixed(2)} ${widget.currency}'),
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
            ),
    );
  }
}
