import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Components/my_textfields/my_numberfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/category_model.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';
import 'package:personalwallettracker/Utils/globals.dart';
import 'package:personalwallettracker/services/firebase/claoud_storage_db/firebase_storage.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';
import 'package:personalwallettracker/services/notifications/notification.dart';

class AddTransactionScreen extends StatefulWidget {
  final CardModel card;
  final String user;
  const AddTransactionScreen({
    super.key,
    required this.card,
    required this.user,
  });

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  final FirebaseDB _firebaseDB = FirebaseDB();
  final FirebaseCloudStorageHelper firebaseCloudHelper =
      FirebaseCloudStorageHelper();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<CategoryModel> _categories = [];
  String? _selectedCategory;
  bool _isLoadingCategories = true;
  bool isExpense = true; // Default to 'Transaction'
  String selectedCardType = 'visa';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _firebaseDB.getCategories(widget.user);
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
      }
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        TransactionModel transaction = TransactionModel(
          cardId: widget.card.id,
          cardName: widget.card.cardName,
          amount: double.parse(_amountController.text),
          category: _selectedCategory.toString(),
          date: selectedDate,
          description: _descriptionController.text,
          isExpense: isExpense,
        );

        bool created = await _firebaseDB.addTransaction(transaction);

        if (created) {
          double amount = isExpense ? -transaction.amount : transaction.amount;
          debugPrint(amount.toString());

          _firebaseDB.updateCardBalance(
            widget.card.id,
            widget.card.balance + amount,
          );
          debugPrint('updated card balance!');

          showSuccessSnachBar('Transaction Created!');
          LocalNotificationService().showNotification(
            title: 'new Transation - ${transaction.description}',
            body: '${transaction.amount} -> ${transaction.cardName}',
          );
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        } else {
          showErrorSnachBar('Error Creating Transaction!');
        }
      } catch (e) {
        if (mounted) {
          showErrorSnachBar('Error creating transaction: $e');
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
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
            ), // Background color of the dialog
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = formatDate(selectedDate);
      });
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingCategories
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.money_rounded,
                          size: 70,
                          color: Color(widget.card.color),
                        ),
                        const SizedBox(height: 10.0),
                        widget.card.cardName.isNotEmpty
                            ? Text(widget.card.cardName)
                            : const Text('Loading card information...'),
                      ],
                    ),
                    const SizedBox(height: 15.0),
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
                            enabled: true,
                          ),
                          // Description
                          MyTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            color: Colors.deepPurple,
                            enabled: true,
                          ),
                          // Category
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              icon: const Icon(
                                Icons.category_outlined,
                                color: Colors.deepPurple,
                              ),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                labelText: 'Category',
                                labelStyle: TextStyle(color: Colors.deepPurple),
                                enabledBorder: OutlineInputBorder(
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
                              items: [
                                ..._categories.map(
                                  (category) => DropdownMenuItem<String>(
                                    value: category.name,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 35.0,
                                          child: categoryIcon(
                                            category.iconName,
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Text(category.name),
                                      ],
                                    ),
                                  ),
                                ),
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
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                labelText: formatDate(selectedDate),
                                labelStyle: const TextStyle(
                                  color: Colors.deepPurple,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.calendar_month_outlined,
                                    color: Colors.deepPurple,
                                  ),
                                  onPressed: () => _selectDate(context),
                                ),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          // Income or Expense = isExpense`
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: isExpense
                                        ? Colors.grey
                                        : Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(width: 30.0),
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
                                Text(
                                  'Expense`',
                                  style: TextStyle(
                                    color: isExpense
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // save transaction
                          
                          MyButton(
                            label: 'Save transaction',
                            onTap: _addTransaction,
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

  void showErrorSnachBar(String message) {
    awesomeTopSnackbar(
      context,
      message,
      iconWithDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.amber.shade400,
      ),
      backgroundColor: Colors.amber,
      icon: const Icon(Icons.close, color: Colors.white),
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
