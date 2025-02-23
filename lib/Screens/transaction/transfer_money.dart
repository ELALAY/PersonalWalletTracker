import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_card.dart';
import 'package:personalwallettracker/Components/my_textfields/my_numberfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';

import '../../services/realtime_db/firebase_db.dart';

class TransferMoney extends StatefulWidget {
  final List<CardModel> myCards;
  final String currency;
  const TransferMoney(
      {super.key, required this.myCards, required this.currency});

  @override
  State<TransferMoney> createState() => _TransferMoneyState();
}

class _TransferMoneyState extends State<TransferMoney> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  bool isLoading = false;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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
                                      currency: widget.currency,
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
                    const SizedBox(height: 10.0),
                    widget.myCards.isNotEmpty
                        ? SmoothPageIndicator(
                            controller: pageSendController,
                            count: widget.myCards.length,
                            effect: const ExpandingDotsEffect(
                                activeDotColor: Colors.deepPurple),
                          )
                        : Container(),
                    const SizedBox(height: 10),
                    //amount to transfer
                    MyNumberField(
                        controller: _amountController,
                        label: 'Amount',
                        color: Colors.pink,
                        enabled: true),
                    MyTextField(
                        controller: _descriptionController,
                        label: 'Desctription',
                        color: Colors.pink,
                        enabled: true),
                    const SizedBox(height: 10),
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
                                      currency: widget.currency,
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
                    const SizedBox(height: 10.0),
                    widget.myCards.isNotEmpty
                        ? SmoothPageIndicator(
                            controller: pageReceiveController,
                            count: widget.myCards.length,
                            effect: const ExpandingDotsEffect(
                                activeDotColor: Colors.deepPurple),
                          )
                        : Container(),
                    const SizedBox(height: 15),
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SlideAction(
                        onSubmit: () async {
                          if (_amountController.text.isNotEmpty) {
                            return transferMoney(
                                widget.myCards[pageSendIndex],
                                widget.myCards[pageReceiveIndex],
                                double.parse(_amountController.text),
                                _descriptionController.text);
                          } else {
                            showErrorSnachBar('Enter an amount!');
                          }
                        },
                        sliderButtonIcon: const Icon(
                          Icons.monetization_on_sharp,
                          color: Colors.pink,
                        ),
                        borderRadius: 12.0,
                        text: '    Slide to transfer',
                        innerColor: Colors.white,
                        outerColor: Colors.pink,
                      ),
                    )),
                  ],
                ),
              ),
            ),
    );
  }

  bool transferMoney(CardModel sendCard, CardModel receiveCard, double amount, String description) {
    if (sendCard != receiveCard) {
      if (amount > 0 && sendCard.balance >= amount) {
        firebaseDatabasehelper.transferMoney(
            fromCard: sendCard, toCard: receiveCard, amount: amount, description: description);
        showSuccessSnachBar(
            'Transfer "${sendCard.cardName}" to "${receiveCard.cardName}" Completed!');

        Navigator.pop(context);
        return true;
      } else {
        showErrorSnachBar('Not enough funds on card!');
      }
    } else {
      showErrorSnachBar('Cards should be different!');
    }

    return false;
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
}
