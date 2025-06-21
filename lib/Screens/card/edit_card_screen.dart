import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Components/my_card.dart';
import 'package:personalwallettracker/Components/my_color_pallette.dart';
import 'package:personalwallettracker/Components/my_textfields/my_numberfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/Screens/home.dart';
import 'package:personalwallettracker/Utils/globals.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';

class EditCardScreen extends StatefulWidget {
  final CardModel card;
  final String currency;

  const EditCardScreen({super.key, required this.card, required this.currency});

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
  bool isLoading = true;

  void _onColorSelected(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize with existing card details
    _cardholderController = TextEditingController(
      text: widget.card.cardHolderName,
    );
    _cardNameController = TextEditingController(text: widget.card.cardName);
    _balanceController = TextEditingController(
      text: widget.card.balance.toString(),
    );
    cardType = widget.card.cardType;
    selectedColor = Color(widget.card.color);
    isLoading = false;
  }

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _toggleArchiveCard() async {
    try {
      CardModel updatedCard = widget.card.toggleArchive();
      await firebaseDatabasehelper.updateCard(updatedCard);

      showInfoSnachBar('Card is archived!');

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const MyHomePage();
          },
        ),
      );
    } catch (e) {
      debugPrint('error: $e');
    }
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating card: $e')));
      }
    }
  }

  void deleteCard() async {
    await firebaseDatabasehelper.deleteCard(widget.card.id);
    showSuccessSnachBar('Card deleted successfully!');
    showWarningSnachBar('Transactions of this card deleted!');
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void _deleteCardDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Deleting Card will delete all related transaction',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                // leading: Icon(transaction['categoryIcon']),
                title: Text('Card Name: ${widget.card.cardName}'),
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
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteCard();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.deepPurple),
              ),
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
            },
          ),
          IconButton(
            onPressed: _deleteCardDialog,
            icon: const Icon(CupertinoIcons.delete_solid),
          ),
          widget.card.isArchived
              ? IconButton(
                  onPressed: _toggleArchiveCard,
                  icon: const Icon(CupertinoIcons.archivebox_fill),
                )
              : IconButton(
                  onPressed: _toggleArchiveCard,
                  icon: const Icon(CupertinoIcons.archivebox),
                ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _openShareDialog(),
          ),
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
                isArchived: widget.card.isArchived,
                onTap: () {},
                currency: widget.currency,
              ),
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Card Owner Name
                    MyTextField(
                      controller: _cardholderController,
                      label: 'Card Holder',
                      color: Colors.deepPurple,
                      enabled: enabledEditkeyInfo,
                    ),
                    const SizedBox(height: 16.0),
                    //Card Name
                    MyTextField(
                      controller: _cardNameController,
                      label: 'Card Name',
                      color: Colors.deepPurple,
                      enabled: true,
                    ),
                    const SizedBox(height: 16.0),
                    //Card Balance
                    MyNumberField(
                      controller: _balanceController,
                      label: 'Balance',
                      color: Colors.deepPurple,
                      enabled: enabledEditkeyInfo,
                    ),
                    const SizedBox(height: 16.0),
                    //Card Type
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
                          DropdownMenuItem(value: 'visa', child: Text('Visa')),
                          DropdownMenuItem(
                            value: 'mastercard',
                            child: Text('Mastercard'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    //Card Color Choice
                    ColorPalette(
                      colors: colorOptions,
                      onColorSelected: _onColorSelected,
                    ),
                    const SizedBox(height: 16.0),
                    //Save Updates
                    MyButton(label: 'Update Card', onTap: _editCard),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openShareDialog() async {
  // Fetch friends of owner (assuming you have a method in your FirebaseDB service)
  List<Person> friends = await firebaseDatabasehelper.getFriends(widget.card.ownerId);

  // Map to keep track of which friends are already shared
  Map<String, bool> sharedMap = {
    for (var friend in friends)
      friend.id: widget.card.sharedWith.contains(friend.id),
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: 400,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Share Card With Friends',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
                  Expanded(
                    child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        final isShared = sharedMap[friend.id] ?? false;
                        return CheckboxListTile(
                          value: isShared,
                          title: Text(friend.username),
                          subtitle: Text(friend.email),
                          onChanged: (val) {
                            setStateDialog(() {
                              sharedMap[friend.id] = val ?? false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Build new sharedWith list from sharedMap
                      List<String> newSharedWith = sharedMap.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList();

                      // Update card's sharedWith list in your db
                      CardModel updatedCard = CardModel.withId(
                        id: widget.card.id,
                        cardName: widget.card.cardName,
                        balance: widget.card.balance,
                        cardHolderName: widget.card.cardHolderName,
                        ownerId: widget.card.ownerId,
                        cardType: widget.card.cardType,
                        color: widget.card.color,
                        isArchived: widget.card.isArchived,
                        sharedWith: newSharedWith,
                      );

                      await firebaseDatabasehelper.updateCard(updatedCard);

                      setState(() {
                        // Update local card reference to reflect changes
                        widget.card.sharedWith.clear();
                        widget.card.sharedWith.addAll(newSharedWith);
                      });

                      Navigator.of(context).pop();

                      // Optional: show success message
                      showSuccessSnachBar('Shared users updated!');
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  void showErrorSnachBar(String message) {
    awesomeTopSnackbar(
      context,
      message,
      iconWithDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.red.shade400,
      ),
      backgroundColor: Colors.red,
      icon: const Icon(Icons.close, color: Colors.white),
    );
  }

  void showWarningSnachBar(String message) {
    awesomeTopSnackbar(
      context,
      message,
      iconWithDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.amber.shade400,
      ),
      backgroundColor: Colors.amber,
      icon: const Icon(Icons.warning_amber, color: Colors.white),
    );
  }

  void showInfoSnachBar(String message) {
    awesomeTopSnackbar(
      context,
      message,
      iconWithDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.lightBlueAccent.shade400,
      ),
      backgroundColor: Colors.lightBlueAccent,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  void showSuccessSnachBar(String message) {
    awesomeTopSnackbar(
      context,
      message,
      iconWithDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.green.shade400,
      ),
      backgroundColor: Colors.green,
      icon: const Icon(Icons.check, color: Colors.white),
    );
  }
}
