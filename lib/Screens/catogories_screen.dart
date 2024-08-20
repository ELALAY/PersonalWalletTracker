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
                          //edit category
                          leading: IconButton(
                              onPressed: () {
                                _showUpdateCategoryDialog(category);
                                fetchCategories();
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueGrey,
                              )),
                          //delete category
                          trailing: IconButton(
                              onPressed: () {
                                _showDeleteCategoryDialog(category);
                                fetchCategories();
                              },
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.pink,
                              )),
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

  void _showUpdateCategoryDialog(Category category) {
    final TextEditingController newCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update ${category.name}'),
          content: MyTextField(
              controller: newCategoryController,
              label: category.name,
              color: Colors.deepPurple,
              enabled: true),
          actions: [
            MyButton(
                label: 'Update',
                onTap: () {
                  final newCategoryName = newCategoryController.text.trim();
                  if (newCategoryName.isNotEmpty) {
                    editcategory(category, newCategoryName);
                    fetchCategories();
                    Navigator.of(context).pop();
                  }
                }),
          ],
        );
      },
    );
  }

  void _showDeleteCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(category.name),
          actions: [
            MyButton(
                label: 'delete',
                onTap: () {
                  setState(() {
                    categories.remove(category);
                  });
                  deleteCategory(category);
                  fetchCategories();
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  void editcategory(Category catergory, String newName) async {
    try {
      Category newCategory = Category.withId(id: catergory.id, name: newName);
      await firebaseDatabasehelper.updateCategory(newCategory);
      if (mounted) {
        fetchCategories(); // Reload categories
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating category: $e')),
        );
      }
    }
  }

  void _createCategory(String name) async {
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

  void deleteCategory(Category category) async {
    try {
      firebaseDatabasehelper.deleteCategory(category);
      if (mounted) {
        fetchCategories(); // Reload categories
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }
}
