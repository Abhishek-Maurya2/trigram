import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_checkbox.dart';
import 'create_task_page.dart';
import 'task_provider.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;
    final isChecked = taskProvider.isChecked;

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CustomCheckbox(
            value: isChecked[index],
            onChanged: (bool? newValue) {
              taskProvider.toggleChecked(index);
            },
          ),
          title: Text(tasks[index]),
          subtitle: Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              const Text('Tomorrow'),
            ],
          ),
          onTap: () {},
        );
      },
    );
  }
}
