import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';

import '../../Components/my_textfields/my_textfield.dart';
import '../../Models/category_model.dart';
import '../../Utils/globals.dart';
import '../../services/realtime_db/firebase_db.dart';

class EditCategory extends StatefulWidget {
  final CategoryModel category;
  const EditCategory({super.key, required this.category});

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  TextEditingController newCategoryController = TextEditingController();
  String _selectedIcon = 'app_icon';

  @override
  void initState() {
    super.initState();
    // Initialize with existing card details
    newCategoryController =
        TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.iconName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Category'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
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
          MyButton(label: 'save', onTap: saveCategory),
        ],
      ),
    );
  }

  Future<void> saveCategory() async {
    try {
      if (newCategoryController.text.isNotEmpty) {
        CategoryModel category =
            CategoryModel.withId(id: widget.category.id,name: newCategoryController.text, iconName: _selectedIcon);
        await firebaseDatabasehelper.updateCategory(category);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        debugPrint('no name found');
      }
    } catch (e) {
      debugPrint('error creating category');
    }
  }
}
