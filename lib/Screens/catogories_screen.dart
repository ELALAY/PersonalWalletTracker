import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  void reload() {
    isLoading = true;
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
        actions: [
          IconButton(onPressed: reload, icon: const Icon(Icons.refresh))
        ],
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
                        return Slidable(
                            key: const ValueKey(0),

                            // The start action pane is the one at the left or the top side.
                            startActionPane: ActionPane(
                              // A motion is a widget used to control how the pane animates.
                              motion: const StretchMotion(),

                              // All actions are defined in the children parameter.
                              children: [
                                // A SlidableAction can have an icon and/or a label.
                                SlidableAction(
                                  onPressed: (context) {
                                    _showUpdateCategoryDialog(category);
                                    fetchCategories();
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Update',
                                ),
                              ],
                            ),

                            // The start action pane is the one at the left or the top side.
                            endActionPane: ActionPane(
                              // A motion is a widget used to control how the pane animates.
                              motion: const StretchMotion(),

                              // All actions are defined in the children parameter.
                              children: [
                                // A SlidableAction can have an icon and/or a label.
                                SlidableAction(
                                  onPressed: (context) {
                                    _showDeleteCategoryDialog(category);
                                    fetchCategories();
                                  },
                                  backgroundColor:
                                      const Color.fromARGB(255, 192, 174, 174),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_forever_outlined,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(category.name),
                              leading: SizedBox(
                                  height: 35.0,
                                  child: categoryIcon(category.name)),
                            ));
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

  Image categoryIcon(String name) {
    try {
      return Image.asset(
        'lib/Images/${name.toLowerCase()}.png',
      );
    } catch (e) {
      throw Exception('Firebase error: $e');
    }
  }

  void _showCreateCategoryDialog() {
    final TextEditingController newCategoryController = TextEditingController();
    String errMsg = '*';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                  controller: newCategoryController,
                  label: 'Category Name',
                  color: Colors.deepPurple,
                  enabled: true),
              Text(
                errMsg,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: [
            MyButton(
                label: 'Create',
                onTap: () async {
                  final newCategoryName = newCategoryController.text.trim();
                  if (newCategoryName.isNotEmpty) {
                    bool created = await _createCategory(newCategoryName);
                    if (!created) {
                      setState(() {
                        errMsg = 'Category already created';
                      });
                    } else {
                      fetchCategories();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
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
                    Navigator.of(context).pop();
                    fetchCategories();
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
                  Navigator.of(context).pop();
                  fetchCategories();
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
      setState(() {
        fetchCategories(); // Reload categories
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating category: $e')),
      );
    }
  }

  Future<bool> _createCategory(String name) async {
    final newCategory = Category(name: name);
    try {
      bool created = await firebaseDatabasehelper.createCategory(newCategory);
      if (created) {
        setState(() {
          fetchCategories(); // Reload categories
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating category: $e')),
      );
      return false;
    }
  }

  void deleteCategory(Category category) async {
    try {
      firebaseDatabasehelper.deleteCategory(category);
      setState(() {
        fetchCategories(); // Reload categories
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: $e')),
      );
    }
  }
}
