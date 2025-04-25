import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final reminders = taskProvider.getReminders();

        if (reminders.isEmpty) {
          return const Center(
            child: Text(
                'No reminders yet. Add tasks with reminders to see them here.'),
          );
        }

        return ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            final timeString =
                TimeOfDay.fromDateTime(reminder['time']).format(context);
            final dateString =
                '${reminder['time'].day}/${reminder['time'].month}/${reminder['time'].year}';

            return SwitchListTile(
              title: Text(reminder['title']),
              subtitle: Text('Date: $dateString\nTime: $timeString'),
              value: reminder['active'],
              onChanged: (bool value) {
                // Find task index in the task list
                final taskIndex = taskProvider.tasks
                    .indexWhere((task) => task.id == reminder['id']);
                if (taskIndex != -1) {
                  taskProvider.toggleTaskChecked(taskIndex);
                }
              },
              secondary: const Icon(Icons.alarm),
            );
          },
        );
      },
    );
  }
}
