import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MyCard extends StatefulWidget {
  final bool isArchived;
  final String cardHolder;
  final double balance;
  final String cardName;
  final Color color;
  final VoidCallback onTap;
  final String cardType; // Add card type (e.g., Visa, Mastercard)
  final String currency;

  const MyCard({
    super.key,
    required this.cardHolder,
    required this.balance,
    required this.cardName,
    required this.color,
    required this.onTap,
    required this.cardType, // Initialize cardType
    this.isArchived = false,
    required this.currency,
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  bool obscure = true;

  void toggleObscure() {
    setState(() {
      obscure = !obscure;
    });
  }

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
            BoxShadow(color: Colors.grey, spreadRadius: 2, blurRadius: 2),
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
            Text(
              obscure ? '*****' : '${widget.balance.toStringAsFixed(2)} ${widget.currency}',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                decoration: widget.isArchived
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            Text(
              widget.cardName,
              style: TextStyle(
                color: Colors.white,
                decoration: widget.isArchived
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
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
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onTap, //edit card
                      icon: const Icon(Icons.edit, color: Colors.white),
                    ),
                    IconButton(
                        onPressed: toggleObscure,
                        icon: obscure
                            ? const Icon(
                                CupertinoIcons.eye_slash_fill,
                                color: Colors.white,
                              )
                            : const Icon(
                                CupertinoIcons.eye_solid,
                                color: Colors.white,
                                
                              )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
