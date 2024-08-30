import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Components/my_textfields/my_textfield.dart';
import 'package:personalwallettracker/Screens/categories/create_category.dart';

import '../../Models/category_model.dart';
import '../../Utils/globals.dart';
import '../../services/realtime_db/firebase_db.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  List<CategoryModel> categories = [];
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
    List<CategoryModel> temp = await firebaseDatabasehelper.getCategories();
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
                                  child: categoryIcon(category.iconName)),
                            ));
                      }),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCategory,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }


  void _showUpdateCategoryDialog(CategoryModel category) {
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

  void _showDeleteCategoryDialog(CategoryModel category) {
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

  void editcategory(CategoryModel catergory, String newName) async {
    // try {
    //   Category newCategory = Category.withId(id: catergory.id, name: newName);
    //   await firebaseDatabasehelper.updateCategory(newCategory);
    //   setState(() {
    //     fetchCategories(); // Reload categories
    //   });
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error updating category: $e')),
    //   );
    // }
  }

  void _createCategory() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const CreateCategory(); // replace with your settings screen
    })).then((value) => reload());
  }

  void deleteCategory(CategoryModel category) async {
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
