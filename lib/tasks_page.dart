import 'package:flutter/material.dart';
import 'custom_checkbox.dart'; // Import the CustomCheckbox
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // Dummy list of tasks
  final List<String> _tasks =
      List.generate(15, (index) => 'Task ${index + 1}: Do something important');

  // Track checkbox state for each task
  late List<bool> _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = List.generate(_tasks.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CustomCheckbox( // Use CustomCheckbox
            value: _isChecked[index],
            onChanged: (bool? newValue) {
              setState(() {
                _isChecked[index] = newValue ?? false;
                // TODO: Implement task completion logic
              });
            },
          ),
          title: Text(_tasks[index]),
          subtitle: Row(
            children: [
              const Icon(Icons.calendar_today, size: 16), // Calendar icon
              const SizedBox(width: 4), // Spacing
              Text('Tomorrow'),
            ],
          ),
          onTap: () {
            // TODO: Implement task tap action
          },
        );
      },
    );
  }
}
