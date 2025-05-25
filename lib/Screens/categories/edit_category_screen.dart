import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Models/transaction_model.dart';

import '../../Components/my_textfields/my_textfield.dart';
import '../../Models/card_model.dart';
import '../../Models/category_model.dart';
import '../../Utils/globals.dart';
import '../../services/realtime_db/firebase_db.dart';

class EditCategory extends StatefulWidget {
  final CategoryModel category;
  final String user;
  const EditCategory({super.key, required this.category, required this.user});

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  TextEditingController newCategoryController = TextEditingController();
  String _selectedIcon = 'app_icon';
  int transactions = 0;
  List<CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing card details
    fetchCards();
    newCategoryController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.iconName;
  }

  void fetchCards() async {
    List<TransactionModel> trans = [];
    List<CardModel> cards =
        await firebaseDatabasehelper.getUserCards(widget.user);
    debugPrint("${cards.length}");
    
    if (cards.isNotEmpty) {
      List<String> cardsIds = cards.map((card) => card.id).toList();
      debugPrint("${cardsIds.length}");
      
      trans = await firebaseDatabasehelper
          .fetchTransactionsByCategoryAndCards(widget.category.name, cardsIds);
      debugPrint("${trans.length}");
    }
    setState(() {
      transactions = trans.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Category'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
        actions: [
          TextButton(onPressed: () {}, child: Text("$transactions")),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 365.0,
            child: MyTextField(
                controller: newCategoryController,
                label: 'Category Name',
                color: Colors.deepPurple,
                enabled: true),
          ),
          Container(
            height: 300.0,
            width: 350.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.deepPurple),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: iconNames.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemBuilder: (context, index) {
                String iconName = iconNames[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconName;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedIcon == iconName
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'lib/Images/$iconName.png',
                      height: 35,
                      width: 35,
                    ),
                  ),
                );
              },
            ),
          ),
          MyButton(label: 'save', onTap: _showAlertDialogue),
        ],
      ),
    );
  }

  void _showAlertDialogue() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning!'),
          content: const Text('Updating a category may affect transactions!'),
          actions: [
            Row(
              children: [
                MyButton(
                    label: 'Cancel',
                    onTap: () {
                      Navigator.of(context).pop();
                    }),
                MyButton(
                    label: 'Submit',
                    onTap: () {
                      Navigator.of(context).pop();
                      saveCategory();
                    }),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> saveCategory() async {
    try {
      if (newCategoryController.text.isNotEmpty) {
        CategoryModel category = CategoryModel.withId(
            id: widget.category.id,
            name: newCategoryController.text,
            iconName: _selectedIcon,
            ownerId: widget.category.ownerId);
        await firebaseDatabasehelper.updateCategory(
            widget.category.name, category);
        showSuccessSnachBar('Category updated successfully!');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        showInfoSnachBar('Name should be filled!');
      }
    } catch (e) {
      showErrorSnachBar('Error updating category');
    }
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
