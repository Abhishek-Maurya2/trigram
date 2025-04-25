import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_checkbox.dart';
import 'task_provider.dart';
import 'create_task_page.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;

        return Column(
          children: [
            // Filter button in top-right
            Padding(
              padding:
                  const EdgeInsets.only(right: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: AnimatedRotation(
                    turns: taskProvider.sortByNewest
                        ? 0.25
                        : 0.7, // 0.5 turns = 180 degrees
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.sync_alt),
                  ),
                  onPressed: () {
                    taskProvider.toggleSortOrder();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          taskProvider.sortByNewest
                              ? 'Sorting by newest first'
                              : 'Sorting by oldest first',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: taskProvider.sortByNewest
                      ? 'Newest first'
                      : 'Oldest first',
                ),
              ),
            ),

            // Task list
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text('No tasks yet. Tap + to add a new task.'),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskItem(
                            context, task, index, taskProvider);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, int taskIndex,
      TaskProvider taskProvider) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateTaskPage(taskToEdit: task),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCheckbox(
                    value: task.isChecked,
                    onChanged: (bool? newValue) {
                      taskProvider.toggleTaskChecked(taskIndex);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration:
                            task.isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),

              // Description if available
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 36.0, top: 8.0, right: 8.0),
                  child: Text(
                    task.description!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),

              // Date and time chips
              if (task.dateTime != null)
                Padding(
                  padding: const EdgeInsets.only(left: 36.0, top: 8.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                            '${task.dateTime!.day}/${task.dateTime!.month}/${task.dateTime!.year}'),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      Chip(
                        avatar: const Icon(Icons.access_time, size: 16),
                        label: Text(TimeOfDay.fromDateTime(task.dateTime!)
                            .format(context)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),

              // Subtasks section
              if (task.subTasks.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 36.0, top: 16.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      ...task.subTasks.asMap().entries.map((entry) {
                        final subtaskIndex = entry.key;
                        final subtask = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomCheckbox(
                                value: subtask.isChecked,
                                onChanged: (bool? value) {
                                  taskProvider.toggleSubTaskChecked(
                                      taskIndex, subtaskIndex);
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 1.5),
                                  child: Text(
                                    subtask.title,
                                    style: TextStyle(
                                      decoration: subtask.isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

              // Note section
              if (task.note != null && task.note!.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 36.0, top: 16.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Note:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(task.note!),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
