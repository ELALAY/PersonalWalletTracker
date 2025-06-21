import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:personalwallettracker/Components/my_buttons/my_button.dart';
import 'package:personalwallettracker/services/firebase/claoud_storage_db/firebase_storage.dart';
import 'package:personalwallettracker/services/firebase/realtime_db/firebase_db.dart';
import 'package:personalwallettracker/services/notifications/notification.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final String user;
  const NotificationSettingsScreen({super.key, required this.user});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final FirebaseDB _firebaseDB = FirebaseDB();
  final FirebaseCloudStorageHelper firebaseCloudHelper =
      FirebaseCloudStorageHelper();
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  bool enableNotifications = true;
  bool transactionsAlert = true;
  bool budgetLimitAlert = true;
  bool goalProgressApdates = true;
  bool sharedActivitiesActivities = true;

  List<PendingNotificationRequest> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadScheduledNotifications();
  }

  Future<void> _loadScheduledNotifications() async {
    final pending = await _localNotificationService.getPendingNotifications();
    setState(() {
      _pendingNotifications = pending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              SwitchListTile(
                title: const Text('Transaction Alerts'),
                value: transactionsAlert,
                onChanged: (value) => setState(() => transactionsAlert = value),
              ),
              SwitchListTile(
                title: const Text('Budget Limit Alerts'),
                value: budgetLimitAlert,
                onChanged: (value) => setState(() => budgetLimitAlert = value),
              ),
              SwitchListTile(
                title: const Text('Goal Progress Updates'),
                value: goalProgressApdates,
                onChanged: (value) =>
                    setState(() => goalProgressApdates = value),
              ),
              SwitchListTile(
                title: const Text('Shared Card Activity'),
                value: sharedActivitiesActivities,
                onChanged: (value) =>
                    setState(() => sharedActivitiesActivities = value),
              ),
            ],

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MyButton(label: 'Send Now', onTap: sendNotification),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MyButton(
                    label: 'Schedule',
                    onTap: _showScheduleDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MyButton(
                    label: 'Cancel All',
                    onTap: cancelAllScheculedNotifications,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(child: MyButton(label: 'Save Settings', onTap: _saveSettings)),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              'Scheduled Notifications:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            _pendingNotifications.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No scheduled notifications.'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pendingNotifications.length,
                    itemBuilder: (context, index) {
                      final notif = _pendingNotifications[index];
                      return ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(notif.title ?? 'No Title'),
                        subtitle: Text(notif.body ?? 'No Body'),
                        trailing: Text('ID: ${notif.id}'),
                      );
                    },
                  ),
          ],
        ),
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
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                            setStateDialog(() {
                              selectedDateTime = dt;
                            });
                          }
                        }
                      },
                    ),
                    if (selectedDateTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Scheduled for: $selectedDateTime'),
                      ),
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
                        id: DateTime.now().millisecondsSinceEpoch.remainder(
                          100000,
                        ),
                        title: titleController.text,
                        body: bodyController.text,
                        hour: selectedDateTime!.hour,
                        minute: selectedDateTime!.minute,
                      );
                      debugPrint('scheduled: ${titleController.text} ${selectedDateTime!.hour} ${selectedDateTime!.minute}');
                      Navigator.of(context).pop();
                      _loadScheduledNotifications(); // Refresh list
                    }
                  },
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void sendNotification() async {
    await _localNotificationService.showNotification(
      title: 'Test Notification',
      body: 'This is a test notification',
    );
  }

  void cancelAllScheculedNotifications() async {
    await _localNotificationService.cancelAllNotifications();
    _loadScheduledNotifications(); // Refresh after cancel
  }

  void _saveSettings() async {
    await _firebaseDB.updateUserNotificationSettings(
      widget.user,
      enableNotifications,
      transactionsAlert,
      budgetLimitAlert,
      goalProgressApdates,
      sharedActivitiesActivities,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Settings saved")));
  }
}
