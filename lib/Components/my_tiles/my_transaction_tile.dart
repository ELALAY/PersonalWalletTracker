import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';

import '../../Models/card_model.dart';
import '../../Screens/transaction/edit_transaction_screen.dart';

class MyTransactionTile extends StatefulWidget {
  final TransactionModel transaction;
  const MyTransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  State<MyTransactionTile> createState() => _MyTransactionTileState();
}

class _MyTransactionTileState extends State<MyTransactionTile> {
  get firebaseDB => null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
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
                deleteTransaction(widget.transaction);
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
                editTransaction(widget.transaction);
              },
              backgroundColor: const Color.fromARGB(255, 192, 174, 174),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
          ],
        ),
        child: ListTile(
          tileColor: Colors.grey.shade200,
          title: Text(
            widget.transaction.description,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle:
              Text('${formatDate(widget.transaction.date)} - ${widget.transaction.category}'),
          trailing: Text(
            '${widget.transaction.isExpense ? '-' : '+'}\$${widget.transaction.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
                color: widget.transaction.isExpense ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
          onTap: () {
            // Show transaction details
            _showTransactionDetails(widget.transaction);
          },
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  void editTransaction(TransactionModel transaction) async {
    
      CardModel cardTemp = await firebaseDB.getCardById(widget.transaction.cardId);
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return EditTransactionScreen(
          card: cardTemp,
          transaction: transaction,
        ); // replace with your settings screen
      }));
    
  }

  void deleteTransaction(TransactionModel transaction) async {
    bool deleted = await firebaseDB.deleteTransaction(transaction);
    if (deleted) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Transaction ${transaction.description} deleted!')),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting transaction')),
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
}
