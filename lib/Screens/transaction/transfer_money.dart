import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_card.dart';
import 'package:personalwallettracker/Components/my_textfield.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TransferMoney extends StatefulWidget {
  final List<CardModel> myCards;
  const TransferMoney({super.key, required this.myCards});

  @override
  State<TransferMoney> createState() => _TransferMoneyState();
}

class _TransferMoneyState extends State<TransferMoney> {
  bool isLoading = false;
  final TextEditingController _amountController = TextEditingController();
  final PageController pageSendController = PageController();
  final PageController pageReceiveController = PageController();
  // Card indices for sending and receiving
  int pageSendIndex = 0;
  int pageReceiveIndex = 0;

  @override
  void initState() {
    super.initState();
    pageSendController.addListener(() {
      final newIndex = pageSendController.page?.round() ?? 0;
      if (newIndex != pageSendIndex) {
        setState(() {
          pageSendIndex = newIndex;
        });
      }
    });
    pageReceiveController.addListener(() {
      final newIndex = pageReceiveController.page?.round() ?? 0;
      if (newIndex != pageReceiveIndex) {
        setState(() {
          pageReceiveIndex = newIndex;
        });
      }
    });
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //Card to Send
                    SizedBox(
                      height: 200.0,
                      child: PageView(
                        controller: pageSendController,
                        scrollDirection: Axis.horizontal,
                        children: widget.myCards.isNotEmpty
                            ? widget.myCards
                                .map((card) => MyCard(
                                      cardHolder: card.cardHolderName,
                                      balance: card.balance,
                                      cardName: card.cardName,
                                      cardType: card.cardType,
                                      color: Color(card.color),
                                      onTap: () {}, //navUpdateCard,
                                    ))
                                .toList()
                            : [
                                const Center(
                                  child: Text(
                                    'No Cards Found! Create a Card!',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w200),
                                  ),
                                )
                              ],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    widget.myCards.isNotEmpty
                        ? SmoothPageIndicator(
                            controller: pageSendController,
                            count: widget.myCards.length,
                            effect: const ExpandingDotsEffect(
                                activeDotColor: Colors.deepPurple),
                          )
                        : Container(),
                    const SizedBox(height: 20),
                    //amountn & send button
                    Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                              controller: _amountController,
                              label: 'Amount',
                              color: Colors.pink,
                              enabled: true),
                        ),
                        GestureDetector(
                          onTap: transferMoney,
                          child: Container(
                            height: 50.0,
                            width: 50.0,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'lib/Images/card_receive.png',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    //Card to receive
                    SizedBox(
                      height: 200.0,
                      child: PageView(
                        controller: pageReceiveController,
                        scrollDirection: Axis.horizontal,
                        children: widget.myCards.isNotEmpty
                            ? widget.myCards
                                .map((card) => MyCard(
                                      cardHolder: card.cardHolderName,
                                      balance: card.balance,
                                      cardName: card.cardName,
                                      cardType: card.cardType,
                                      color: Color(card.color),
                                      onTap: () {}, //navUpdateCard,
                                    ))
                                .toList()
                            : [
                                const Center(
                                  child: Text(
                                    'No Cards Found! Create a Card!',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w200),
                                  ),
                                )
                              ],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    widget.myCards.isNotEmpty
                        ? SmoothPageIndicator(
                            controller: pageReceiveController,
                            count: widget.myCards.length,
                            effect: const ExpandingDotsEffect(
                                activeDotColor: Colors.deepPurple),
                          )
                        : Container(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  void transferMoney () {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Transfer Money'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                // leading: Icon(transaction['categoryIcon']),
                title:
                    Text(widget.myCards[pageSendIndex].cardName),
                subtitle: Text(widget.myCards[pageReceiveIndex].cardName),
              ),
              const SizedBox(height: 16.0),
              Text('Amount: ${_amountController.text}'),
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
