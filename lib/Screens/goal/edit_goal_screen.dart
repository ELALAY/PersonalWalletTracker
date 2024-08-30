import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Components/my_buttons/my_button.dart';
import '../../Components/my_textfields/my_numberfield.dart';
import '../../Components/my_textfields/my_textfield.dart';
import '../../Models/goal_model.dart';
import '../../Utils/globals.dart';
import '../../services/realtime_db/firebase_db.dart';

class EditGoalScreen extends StatefulWidget {
  final GoalModel goal;
  const EditGoalScreen({super.key, required this.goal});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  FirebaseDB firebaseDatabasehelper = FirebaseDB();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _targetAmountController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedIcon = 'app_icon'; // Default selected icon
  bool isLoading = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      GoalModel newGoal = GoalModel.withId(
        id: widget.goal.id,
        name: _nameController.text,
        targetAmount: double.parse(_targetAmountController.text),
        endDate: _selectedDate,
        uid: widget.goal.uid,
        goalIcon: _selectedIcon,
      );

      // Save goal to Firestore or any other database
      await firebaseDatabasehelper.updateGoal(newGoal);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with existing card details
    _nameController = TextEditingController(text: widget.goal.name);
    _targetAmountController =
        TextEditingController(text: widget.goal.targetAmount.toString());
    _dateController =
        TextEditingController(text: formatDate(widget.goal.endDate));
    _selectedIcon = widget.goal.goalIcon;

    isLoading = false;
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.name),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                //goal name
                MyTextField(
                    controller: _nameController,
                    label: 'Goal Name',
                    color: Colors.deepPurple,
                    enabled: true),
                //target amount
                MyNumberField(
                    controller: _targetAmountController,
                    label: 'Target Amount',
                    color: Colors.deepPurple,
                    enabled: true),
                // Date Picker
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple),
                      ),
                      labelText: formatDate(_selectedDate),
                      labelStyle: const TextStyle(color: Colors.deepPurple),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_month_outlined,
                            color: Colors.deepPurple),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                const SizedBox(height: 20),
                MyButton(label: 'Save goal', onTap: _saveGoal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
