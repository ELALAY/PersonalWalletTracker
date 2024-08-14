import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_card.dart';
import 'package:personalwallettracker/Components/my_color_pallette.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';
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
  late String cardType;
  late Color selectedColor;
  bool enabledEditkeyInfo = false;

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
        TextEditingController(text: widget.card.cardHolderName);
    _cardNameController = TextEditingController(text: widget.card.cardName);
    _balanceController =
        TextEditingController(text: widget.card.balance.toString());
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
          cardHolderName: _cardholderController.text,
          ownerId: widget.card.ownerId,
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

  void deleteCard() async {
    await firebaseDatabasehelper.deleteCard(widget.card.id);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _deleteCardDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deleting Card will delete all related transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                // leading: Icon(transaction['categoryIcon']),
                title:
                    Text('Card Name: ${widget.card.cardName}'),
                subtitle: Text('Card Holder: ${widget.card.cardHolderName}'),
              ),
              const SizedBox(height: 16.0),
              Text('Balance: \$${widget.card.balance.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.deepPurple),),
            ),
            TextButton(
              onPressed: () {
                deleteCard();
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.deepPurple),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Card'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
        actions: [
          CupertinoSwitch(
              value: enabledEditkeyInfo,
              onChanged: (value) {
                setState(() {
                  enabledEditkeyInfo = value;
                });
              }),
          IconButton(onPressed: _deleteCardDialog, icon: const Icon(CupertinoIcons.delete_solid)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyCard(
                cardHolder: _cardholderController.text,
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
                    //Card Owner Name
                    TextFormField(
                      controller: _cardholderController,
                      enabled: enabledEditkeyInfo,
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
                      enabled: enabledEditkeyInfo,
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
