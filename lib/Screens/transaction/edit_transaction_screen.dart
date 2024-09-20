import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_textfields/my_numberfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/category_model.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
import 'package:personalwallettracker/services/realtime_db/firebase_db.dart';

import '../../Utils/globals.dart';
import '../categories/create_category_screen.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;
  final CardModel card;
  const EditTransactionScreen(
      {super.key, required this.card, required this.transaction});

  @override
  EditTransactionScreenState createState() => EditTransactionScreenState();
}

class EditTransactionScreenState extends State<EditTransactionScreen> {
  final FirebaseDB _firebaseDB = FirebaseDB();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<CategoryModel> _categories = [];
  String? _selectedCategory;
  bool _isLoadingCategories = true;
  bool isExpense = true; // Default to 'Transaction'
  //disable key info edit
  bool enabledEditkeyInfo = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    // Initialize with existing card details
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _dateController =
        TextEditingController(text: formatDate(widget.transaction.date));
    _selectedCategory = widget.transaction.category;
    isExpense = widget.transaction.isExpense;
    selectedDate = widget.transaction.date;
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _firebaseDB.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _editTransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        TransactionModel transaction = TransactionModel.withId(
          id: widget.transaction.id,
          cardId: widget.transaction.cardId,
          cardName: widget.transaction.cardName,
          amount: double.parse(_amountController.text),
          category: _selectedCategory.toString(),
          date: selectedDate,
          description: _descriptionController.text,
          isExpense: isExpense,
        );
        debugPrint(transaction.toString());
        _firebaseDB.updateTransaction(transaction);

        if (mounted) {
          showSuccessSnachBar('transaction Updated');

          Navigator.pop(context); // Go back after adding transaction
        }
      } catch (e) {
        if (mounted) {
          showErrorSnachBar('Error updating transaction: $e');
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.deepPurple, // Body text color
            ),
            dialogBackgroundColor:
                Colors.white, // Background color of the dialog
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        debugPrint('picked: ${picked.toString()}');
        selectedDate = picked;
        debugPrint('selected date: ${selectedDate.toString()}');
        _dateController.text = formatDate(selectedDate);
        debugPrint('date controller:_${_dateController.text}');
      });
    } else {
      debugPrint('picked date is null');
    }
  }

  void deleteTransaction(TransactionModel transaction) async {
    bool deleted = await _firebaseDB.deleteTransaction(transaction);
    if (deleted) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Transaction ${transaction.description} deleted!')),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting transaction')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
        actions: [
          CupertinoSwitch(
              value: enabledEditkeyInfo,
              onChanged: (value) {
                setState(() {
                  enabledEditkeyInfo = value;
                });
              }),
          IconButton(
              onPressed: () {
                deleteTransaction(widget.transaction);
              },
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 25.0,
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.money_rounded,
                          size: 70,
                          color: Color(widget.card.color),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        widget.card.cardName.isNotEmpty
                            ? Text(widget.card.cardName)
                            : const Text('Loading card information...'),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount
                          MyNumberField(
                              controller: _amountController,
                              label: 'Amount',
                              color: Colors.deepPurple,
                              enabled: true),
                          const SizedBox(height: 16.0),
                          // Description
                          MyTextField(
                              controller: _descriptionController,
                              label: 'Description',
                              color: Colors.deepPurple,
                              enabled: true),
                          const SizedBox(height: 16.0),
                          // Category
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              // icon: IconButton(
                              //   onPressed: createCaegory,
                              //   icon: const Icon(
                              //     Icons.add,
                              //     color: Colors.deepPurple,
                              //   ),
                              // ),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                ),
                                labelText: 'Category',
                                labelStyle: TextStyle(color: Colors.deepPurple),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                ),
                              ),
                              items: [
                                ..._categories
                                    .map((category) => DropdownMenuItem<String>(
                                          value: category.name,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                  height: 35.0,
                                                  child: categoryIcon(
                                                      category.iconName)),
                                              const SizedBox(
                                                width: 12.0,
                                              ),
                                              Text(category.name),
                                            ],
                                          ),
                                        )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          // Date Picker
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                ),
                                labelText: formatDate(selectedDate),
                                labelStyle:
                                    const TextStyle(color: Colors.deepPurple),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                      Icons.calendar_month_outlined,
                                      color: Colors.deepPurple),
                                  onPressed: () {
                                    _selectDate(context);
                                    _dateController = TextEditingController(
                                        text: formatDate(selectedDate));
                                  },
                                ),
                              ),
                              readOnly: true,
                              onTap: () {
                                _selectDate(context);
                                _dateController = TextEditingController(
                                    text: formatDate(selectedDate));
                              },
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          // isExpense ? Expense : Income
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('Income',
                                  style: TextStyle(color: Colors.deepPurple)),
                              const SizedBox(width: 20.0),
                              Switch(
                                value: isExpense,
                                onChanged: (value) {
                                  setState(() {
                                    isExpense = value;
                                  });
                                },
                                activeColor: Colors.deepPurple,
                              ),
                              const SizedBox(width: 20.0),
                              const Text('Expense`',
                                  style: TextStyle(color: Colors.deepPurple))
                            ],
                          ),
                          // isRecurring ? Recurring : NotRecurring
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('isRecurring',
                                  style: TextStyle(color: Colors.deepPurple)),
                              const SizedBox(width: 20.0),
                              Switch(
                                value: widget.transaction.isRecurring,
                                onChanged: (value) {
                                  // setState(() {
                                  //   isExpense = value;
                                  // });
                                },
                                activeColor: Colors.deepPurple,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),

                          Center(
                            child: ElevatedButton(
                              onPressed:
                                  _editTransaction, // Disable button if card or category is not selected
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0, vertical: 20.0),
                              ),
                              child: const Text('Edit Transaction'),
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

  void createCaegory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const CreateCategory(); // replace with your settings screen
    }));
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
