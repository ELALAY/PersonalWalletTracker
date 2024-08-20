import 'package:flutter/material.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/category_model.dart';

class CategoryTransactions extends StatefulWidget {
  final Category category;
  final CardModel card;
  const CategoryTransactions(
      {super.key, required this.category, required this.card});

  @override
  State<CategoryTransactions> createState() => _CategoryTransactionsState();
}

class _CategoryTransactionsState extends State<CategoryTransactions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
      ),
      body: Column(children: [],),
    );
  }
}
