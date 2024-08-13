import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_card.dart';
import 'package:personalwallettracker/Components/my_color_pallette.dart';
import 'package:personalwallettracker/Utils/firebase_db.dart';
import '../../Models/card_model.dart';
import '../../Utils/globals.dart';// Import your firebase_db.dart file

class NewCardScreen extends StatefulWidget {
  const NewCardScreen({super.key});

  @override
  State<NewCardScreen> createState() => _NewCardScreenState();
}

class _NewCardScreenState extends State<NewCardScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cardholderController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String title = 'Mr. '; // Default value
  String cardType = 'visa';
  Color selectedColor = Colors.deepPurple; //Default color

  void _onColorSelected(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _addCard() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newCard = CardModel(
          cardName: _cardNameController.text,
          balance: double.parse(_balanceController.text),
          cardHolderName: title + _cardholderController.text,
          cardType: cardType, // Optional field, adjust as needed
          color: selectedColor.value,
        );

        debugPrint('Adding Card: $newCard'); // Debugging statement

        await firebaseDatabasehelper.addCard(newCard);

        debugPrint('Card added');

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding card: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Card'),
        backgroundColor: Colors.deepPurple,
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
                color: selectedColor, // Default color
                onTap: () {},
              ),
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //title
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
                                  color:
                                      Colors.deepPurple, // Deep Purple border
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .deepPurple, // Deep Purple focused border
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
                                  color:
                                      Colors.deepPurple, // Deep Purple border
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .deepPurple, // Deep Purple focused border
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
                    //card name
                    TextFormField(
                      controller: _cardNameController,
                      decoration: const InputDecoration(
                        labelText: 'Card Name',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your card name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    //card color
                    TextFormField(
                      controller: _balanceController,
                      decoration: const InputDecoration(
                        labelText: 'Balance',
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
                    //card type
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
                        onPressed: _addCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 20.0),
                        ),
                        child: const Text('Add Card'),
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
