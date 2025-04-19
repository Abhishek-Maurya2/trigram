import 'package:flutter/material.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  // Dummy list of reminders
  final List<Map<String, dynamic>> _reminders = List.generate(8, (index) => {
    'title': 'Reminder ${index + 1}',
    'time': DateTime.now().add(Duration(hours: index + 1, minutes: index * 15)),
    'active': index % 3 != 0, // Some active, some inactive
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        final timeString = TimeOfDay.fromDateTime(reminder['time']).format(context);

        return SwitchListTile(
          title: Text(reminder['title']),
          subtitle: Text('Time: $timeString'),
          value: reminder['active'],
          onChanged: (bool value) {
            setState(() {
              _reminders[index]['active'] = value;
              // TODO: Add logic to actually schedule/cancel reminder
            });
          },
          secondary: const Icon(Icons.alarm),
        );
      },
    );
  }
}
