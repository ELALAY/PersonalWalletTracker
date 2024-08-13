import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_card.dart';
import 'package:personalwallettracker/Components/my_color_pallette.dart';
import 'package:personalwallettracker/Utils/firebase_db.dart';
import '../../Models/card_model.dart';
import '../../Utils/globals.dart';

class EditCardScreen extends StatefulWidget {
  final CardModel card;

  const EditCardScreen({super.key, required this.card});

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _cardholderController;
  late TextEditingController _cardNameController;
  late TextEditingController _balanceController;
  late String title;
  late String cardType;
  late Color selectedColor;
  bool balanceEnabled = false;

  void _onColorSelected(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize with existing card details
    _cardholderController =
        TextEditingController(text: widget.card.cardHolderName.split(' ').last);
    _cardNameController = TextEditingController(text: widget.card.cardName);
    _balanceController =
        TextEditingController(text: widget.card.balance.toString());
    title = '${widget.card.cardHolderName.split(' ').first} ';
    cardType = widget.card.cardType;
    selectedColor = Color(widget.card.color);
  }

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _editCard() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedCard = CardModel.withId(
          id: widget.card.id,
          cardName: _cardNameController.text,
          balance: double.parse(_balanceController.text),
          cardHolderName: title + _cardholderController.text,
          cardType: cardType,
          color: selectedColor.value,
        );

        await firebaseDatabasehelper.updateCard(updatedCard);

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating card: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
        backgroundColor: Colors.deepPurple,
        actions: [
          CupertinoSwitch(
              value: balanceEnabled,
              onChanged: (value) {
                setState(() {
                  balanceEnabled = value;
                });
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyCard(
                cardHolder: title + _cardholderController.text,
                balance: double.tryParse(_balanceController.text) ?? 0.0,
                cardName: _cardNameController.text,
                cardType: cardType,
                color: selectedColor,
                onTap: () {},
              ),
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 100.0,
                          child: DropdownButtonFormField<String>(
                            value: title,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  title = value;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(color: Colors.deepPurple),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepPurple,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Mr. ',
                                child: Text('Mr. '),
                              ),
                              DropdownMenuItem(
                                value: 'Mrs. ',
                                child: Text('Mrs. '),
                              ),
                              DropdownMenuItem(
                                value: 'Ms. ',
                                child: Text('Ms. '),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        Expanded(
                          child: TextFormField(
                            controller: _cardholderController,
                            decoration: const InputDecoration(
                              labelText: 'Card Holder',
                              labelStyle: TextStyle(color: Colors.deepPurple),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepPurple,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter card holder name';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _cardNameController,
                      decoration: const InputDecoration(
                        labelText: 'Card Name',
                        labelStyle: TextStyle(color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your card name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      enabled: balanceEnabled,
                      controller: _balanceController,
                      decoration: const InputDecoration(
                        labelText: 'Balance',
                        labelStyle: TextStyle(color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the balance';
                        } else if (double.tryParse(value) == null) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: cardType,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            cardType = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Card Type',
                        labelStyle: TextStyle(color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'visa',
                          child: Text('Visa'),
                        ),
                        DropdownMenuItem(
                          value: 'mastercard',
                          child: Text('Mastercard'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ColorPalette(
                        colors: colorOptions,
                        onColorSelected: _onColorSelected),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: _editCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 20.0),
                        ),
                        child: const Text('Update Card'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
