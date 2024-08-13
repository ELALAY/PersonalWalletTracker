import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_card.dart';
import 'package:personalwallettracker/Components/my_color_pallette.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';
import '../../Models/card_model.dart';
import '../../Utils/globals.dart'; // Import your firebase_db.dart file

class NewCardScreen extends StatefulWidget {
  //user and profile info
  final User? user;
  final Map<String, dynamic>? personProfile;
  const NewCardScreen(
      {super.key, required this.user, required this.personProfile});

  @override
  State<NewCardScreen> createState() => _NewCardScreenState();
}

class _NewCardScreenState extends State<NewCardScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _cardholderController = TextEditingController();
  TextEditingController _cardNameController = TextEditingController();
  TextEditingController _balanceController = TextEditingController();
  String cardType = 'visa';
  Color selectedColor = Colors.deepPurple; //Default color
  bool enabledCardHolder = false;
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
        TextEditingController(text: widget.personProfile!['username']);
    _balanceController = TextEditingController(text: '0');
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
          cardHolderName: widget.personProfile!['username'],
          ownerId: widget.user!.uid,
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
        actions: [
          CupertinoSwitch(
              value: enabledCardHolder,
              onChanged: (value) {
                setState(() {
                  enabledCardHolder = value;
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
                cardHolder: widget.personProfile!['username'],
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
                    TextFormField(
                      enabled: enabledCardHolder,
                      controller: _cardholderController,
                      decoration: const InputDecoration(
                        labelText: 'Card Holder',
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
                          return 'Please enter card holder name';
                        }
                        return null;
                      },
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
