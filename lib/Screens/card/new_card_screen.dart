import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Components/my_card.dart';
import 'package:personalwallettracker/Components/my_color_pallette.dart';
import 'package:personalwallettracker/Components/my_textfields/my_numberfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/Utils/globals.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';

class NewCardScreen extends StatefulWidget {
  //user and profile info
  final User user;
  final Person personProfile;
  const NewCardScreen(
      {super.key, required this.user, required this.personProfile});

  @override
  State<NewCardScreen> createState() => _NewCardScreenState();
}

class _NewCardScreenState extends State<NewCardScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _cardholderController = TextEditingController();
  // ignore: prefer_final_fields
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
        TextEditingController(text: widget.personProfile.username);
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
          cardHolderName: widget.personProfile.username,
          ownerId: widget.user.uid,
          cardType: cardType, // Optional field, adjust as needed
          color: selectedColor.value,
        );

        debugPrint('Adding Card: ${newCard.cardName}'); // Debugging statement

        await firebaseDatabasehelper.addCard(newCard);

        debugPrint('Card added');
        showSuccessSnachBar('Card ${newCard.cardName} crated succeffully!');

        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
          showErrorSnachBar('Error adding card');
          debugPrint('Error adding card $e');
        
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
                cardHolder: widget.personProfile.username,
                balance: double.tryParse(_balanceController.text) ?? 0.0,
                cardName: _cardNameController.text,
                cardType: cardType,
                color: selectedColor, // Default color
                onTap: () {},
                currency: widget.personProfile.default_currency,
              ),
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //title
                    MyTextField(
                        controller: _cardholderController,
                        label: 'Card Holder',
                        color: Colors.deepPurple,
                        enabled: true),
                    const SizedBox(height: 16.0),
                    //card name
                    MyTextField(
                        controller: _cardNameController,
                        label: 'Card Name',
                        color: Colors.deepPurple,
                        enabled: true),
                    const SizedBox(height: 16.0),
                    //card color
                    MyNumberField(
                        controller: _balanceController,
                        label: 'Balance',
                        color: Colors.deepPurple,
                        enabled: true),
                    const SizedBox(height: 16.0),
                    //card type
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        value: cardType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              cardType = value;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                          ),
                          labelText: 'Card Type',
                          labelStyle: TextStyle(color: Colors.deepPurple),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple),
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
                    ),
                    const SizedBox(height: 16.0),
                    ColorPalette(
                        colors: colorOptions,
                        onColorSelected: _onColorSelected),
                    const SizedBox(height: 16.0),
                    MyButton(label: 'Add Card', onTap: _addCard),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  void showInfoSnachBar(String message) {
    awesomeTopSnackbar(context, message,
        iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
            color: Colors.lightBlueAccent.shade400),
        backgroundColor: Colors.lightBlueAccent,
        icon: const Icon(
          Icons.info_outline,
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
