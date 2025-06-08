import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Components/my_textfields/my_numberfield.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';
import 'package:personalwallettracker/Models/card_model.dart';
import 'package:personalwallettracker/Models/category_model.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/Models/recurring_transaction_model.dart';
import 'package:personalwallettracker/Utils/globals.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';
import 'package:toggle_switch/toggle_switch.dart';


class EditReccuringTransactionScreen extends StatefulWidget {
  final RecurringTransactionModel transaction;
  final String user;
  final Person personProfile;
  final List<CardModel> myCards;
  const EditReccuringTransactionScreen(
      {super.key,
      required this.transaction,
      required this.user,
      required this.personProfile,
      required this.myCards});

  @override
  State<EditReccuringTransactionScreen> createState() =>
      _EditReccuringTransactionScreenState();
}

class _EditReccuringTransactionScreenState
    extends State<EditReccuringTransactionScreen> {
  final FirebaseDB _firebaseDB = FirebaseDB();

  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<CategoryModel> _categories = [];
  String? _selectedCategory;
  bool isLoading = true;
  bool isExpense = true; // Default to 'Transaction'
  bool isArchived = false;
  int recurranceType = 0; // 0=Monthly, 1=Weekly, 2=By-weekly,

  @override
  void initState() {
    super.initState();
    _loadCategories();
    debugPrint(widget.transaction.recurrenceType.toString());
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _dateController =
        TextEditingController(text: formatDate(widget.transaction.date));
    _selectedCategory = widget.transaction.category;
    isExpense = widget.transaction.isExpense;
    selectedDate = widget.transaction.date;
    isArchived = widget.transaction.isArchived;
    recurranceType = widget.transaction.recurrenceType;
    isLoading = false;
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _firebaseDB.getCategories(widget.user);
      if (mounted) {
        setState(() {
          _categories = categories;
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

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  Future<void> _editransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        RecurringTransactionModel transaction =
            RecurringTransactionModel.withId(
          id: widget.transaction.id,
          ownerId: widget.transaction.ownerId,
          amount: double.parse(_amountController.text),
          category: _selectedCategory.toString(),
          date: selectedDate,
          description: _descriptionController.text,
          isExpense: isExpense,
          recurrenceType: recurranceType,
        );
        await _firebaseDB.updateRecurringTransaction(transaction);
        showSuccessSnachBar('Transaction Created!');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
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
            ), dialogTheme: const DialogThemeData(backgroundColor: Colors.white), // Background color of the dialog
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

  void showDeleteConfirmationDialog(RecurringTransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure you want to delete this transaction'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteTransaction(transaction);
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

  Future<void> toggleArchiveRecurringTransaction() async {
    RecurringTransactionModel rec = RecurringTransactionModel.withId(
        id: widget.transaction.id,
        ownerId: widget.transaction.ownerId,
        amount: widget.transaction.amount,
        category: widget.transaction.category,
        date: widget.transaction.date,
        description: widget.transaction.description,
        isExpense: widget.transaction.isExpense,
        isArchived: !widget.transaction.isArchived,
        recurrenceType: widget.transaction.recurrenceType);

    _firebaseDB.updateRecurringTransaction(rec);
    showSuccessSnachBar('Recurring Transaction Archived toggled!');
    setState(() {
      isArchived = rec.isArchived;
    });
  }

  void deleteTransaction(RecurringTransactionModel transaction) async {
    bool deleted = await _firebaseDB.deleteRecurringTransaction(transaction);
    if (deleted) {
      showSuccessSnachBar('Recurring Transaction deleted Sucessfully!');
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } else {
      showErrorSnachBar('Error deleting Recurring Transaction!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recurring Transaction'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () {
                toggleArchiveRecurringTransaction();
                setState(() {
                  isArchived = !widget.transaction.isArchived;
                });
              },
              icon: isArchived
                  ? const Icon(Icons.unarchive)
                  : const Icon(Icons.unarchive)),
          IconButton(
              onPressed: () {
                showDeleteConfirmationDialog(widget.transaction);
              },
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ))
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50.0,
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
                          // Description
                          MyTextField(
                              controller: _descriptionController,
                              label: 'Description',
                              color: Colors.deepPurple,
                              enabled: true),
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
                                Text('Income',
                                    style: TextStyle(
                                        color: isExpense
                                            ? Colors.grey
                                            : Colors.deepPurple)),
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
                                Text('Expense`',
                                    style: TextStyle(
                                        color: isExpense
                                            ? Colors.deepPurple
                                            : Colors.grey))
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Recurrance Type
                          Center(
                            child: ToggleSwitch(
                              initialLabelIndex: recurranceType,
                              labels: const ['Monthly', 'Weekly', 'By-weekly'],
                              activeBgColor: const [Colors.deepPurple],
                              activeFgColor: Colors.white,
                              inactiveBgColor: Colors.grey.shade300,
                              onToggle: (index) {
                                recurranceType = index!;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // save transaction
                          MyButton(
                              label: 'Save transaction',
                              onTap: _editransaction),
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
