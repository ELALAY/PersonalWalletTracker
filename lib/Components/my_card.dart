import 'package:flutter/material.dart';

import '../Utils/globals.dart';

class MyCard extends StatefulWidget {
  final bool isArchived;
  final String cardHolder;
  final double balance;
  final String cardName;
  final Color color;
  final VoidCallback onTap;
  final String cardType; // Add card type (e.g., Visa, Mastercard)

  const MyCard({
    super.key,
    required this.cardHolder,
    required this.balance,
    required this.cardName,
    required this.color,
    required this.onTap,
    required this.cardType, // Initialize cardType
    this.isArchived = false,
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        width: 300.0,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: widget.isArchived ? Colors.black : widget.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.grey, spreadRadius: 2, blurRadius: 2)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Balance', style: TextStyle(color: Colors.white)),
                if (widget.cardType.isNotEmpty)
                  SizedBox(
                    height: 50.0,
                    child: Image.asset(
                      'lib/Images/${widget.cardType.toLowerCase()}.png',
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              '${widget.balance.toStringAsFixed(2)} $selectedCurrency',
              style:  TextStyle(fontSize: 30, color: Colors.white, decoration: widget.isArchived
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,),
            ),
            Text(
              widget.cardName,
              style: TextStyle(color: Colors.white, decoration: widget.isArchived
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.cardHolder,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: widget.onTap, //edit card
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
