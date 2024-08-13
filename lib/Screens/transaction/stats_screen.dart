import 'package:flutter/material.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
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

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      List<TransactionModel> transactions = [];
      if (selectedCard == 'All') {
        transactions = await _firebaseDB.fetchTransactions();
      } else {
        transactions =
            await _firebaseDB.fetchTransactionsByCardId(selectedCard);
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
                const SizedBox(
                  height: 10.0,
                ),
                SizedBox(
                  height: 300.0,
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
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spending by Category',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
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
                                    return ListTile(
                                      title: Text(category),
                                      trailing:
                                          Text('\$${total.toStringAsFixed(2)}'),
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
}
