import 'package:flutter/material.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/Models/person_model.dart';
import 'package:personalwallettracker/services/firebase/claoud_storage_db/firebase_storage.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';
import 'package:personalwallettracker/services/notifications/notification.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final Person person;
  final String user;
  const NotificationSettingsScreen({
    super.key,
    required this.person,
    required this.user,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final FirebaseDB _firebaseDB = FirebaseDB();
  final FirebaseCloudStorageHelper firebaseCloudHelper =
      FirebaseCloudStorageHelper();
  bool enableNotifications = true;
  bool transactionsAlert = true;
  bool budgetLimitAlert = true;
  bool goalProgressApdates = true;
  bool sharedActivitiesActivities = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        children: [
          // Enable notifications
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: enableNotifications,
            onChanged: (value) {
              setState(() {
                enableNotifications = value;
              });
            },
          ),
          if (enableNotifications) ...[
            // Transactions Alerts
            SwitchListTile(
              title: const Text('Transaction Alerts'),
              value: transactionsAlert,
              onChanged: (value) {
                setState(() {
                  transactionsAlert = value;
                });
              },
            ),
            // budget limit Alerts
            SwitchListTile(
              title: const Text('Budget Limit Alerts'),
              value: budgetLimitAlert,
              onChanged: (value) {
                setState(() {
                  budgetLimitAlert = value;
                });
              },
            ),
            // goal progress updates
            SwitchListTile(
              title: const Text('Goal Progress Updates'),
              value: goalProgressApdates,
              onChanged: (value) {
                setState(() {
                  goalProgressApdates = value;
                });
              },
            ),
            // Shared Card Activity
            SwitchListTile(
              title: const Text('Shared Card Activity'),
              value: sharedActivitiesActivities,
              onChanged: (value) {
                setState(() {
                  sharedActivitiesActivities = value;
                });
              },
            ),
          ],
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyButton(label: 'Save Settings', onTap: _saveSettings),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyButton(label: 'Send noti', onTap: sendNotification),
                  MyButton(label: 'Schedule Notifications', onTap: _showScheduleDialog),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    DateTime? selectedDateTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Schedule Notification'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Body'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pick Date & Time'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(
                        const Duration(minutes: 1),
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time != null) {
                        final dt = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                        selectedDateTime = dt;
                        setState(() {}); // Update dialog
                      }
                    }
                  },
                ),
                if (selectedDateTime != null)
                  Text('Scheduled for: ${selectedDateTime.toString()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDateTime != null) {
                  LocalNotificationService.scheduleNotification(
                    id: 0,
                    title: titleController.text,
                    body: bodyController.text,
                    hour: selectedDateTime!.hour,
                    minute: selectedDateTime!.minute,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Schedule'),
            ),
          ],
        );
      },
    );
  }

  void sendNotification() async {
    LocalNotificationService().showNotification(
      title: 'test Noti',
      body: 'test body for noti',
    );
  }

  void _saveSettings() async {
    // Save to Firestore, SharedPreferences, or your backend
    await _firebaseDB.updateUserNotificationSettings(
      widget.person.id,
      enableNotifications,
      transactionsAlert,
      budgetLimitAlert,
      goalProgressApdates,
      sharedActivitiesActivities,
    );
  }
}
