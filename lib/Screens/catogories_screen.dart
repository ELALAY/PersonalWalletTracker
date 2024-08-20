import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';

import '../Models/category_model.dart';
import '../services/realtime_db/firebase_db.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    isLoading = false;
  }

  void fetchCategories() async {
    List<Category> temp = await firebaseDatabasehelper.getCategories();
    setState(() {
      categories = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0.0,
        title: const Text('Categories'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          title: Text(category.name),
                        );
                      }),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCategoryDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateCategoryDialog() {
    final TextEditingController newCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Category'),
          content: MyTextField(
              controller: newCategoryController,
              label: 'Category Name',
              color: Colors.deepPurple,
              enabled: true),
          actions: [
            MyButton(
                label: 'Create',
                onTap: () {
                  final newCategoryName = newCategoryController.text.trim();
                  if (newCategoryName.isNotEmpty) {
                    _createCategory(newCategoryName);
                    fetchCategories();
                    Navigator.of(context).pop();
                  }
                }),
          ],
        );
      },
    );
  }

  Future<void> _createCategory(String name) async {
    final newCategory = Category(name: name);
    try {
      await firebaseDatabasehelper.createCategory(newCategory);
      if (mounted) {
        fetchCategories(); // Reload categories
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating category: $e')),
        );
      }
    }
  }
}
