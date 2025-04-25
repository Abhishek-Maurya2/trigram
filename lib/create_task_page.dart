import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

class CreateTaskPage extends StatefulWidget {
  final Task? taskToEdit;

  const CreateTaskPage({Key? key, this.taskToEdit}) : super(key: key);

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final _subTaskController = TextEditingController();

  List<SubTask> _subTasks = [];
  DateTime? _date;
  TimeOfDay? _time;
  bool _hasReminder = false;
  bool _hasNote = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _isEditing = true;
      _titleController.text = widget.taskToEdit!.title;

      if (widget.taskToEdit!.description != null) {
        _descriptionController.text = widget.taskToEdit!.description!;
      }

      _subTasks = List.from(widget.taskToEdit!.subTasks);

      if (widget.taskToEdit!.dateTime != null) {
        _hasReminder = true;
        _date = widget.taskToEdit!.dateTime;
        _time = TimeOfDay.fromDateTime(widget.taskToEdit!.dateTime!);
      }

      if (widget.taskToEdit!.note != null &&
          widget.taskToEdit!.note!.isNotEmpty) {
        _hasNote = true;
        _noteController.text = widget.taskToEdit!.note!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _subTaskController.dispose();
    super.dispose();
  }

  DateTime? get _dateTime {
    if (_date == null) return null;
    if (_time == null) return _date;

    return DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Create New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Sub-tasks section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sub-tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // List of added sub-tasks
                      ..._subTasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subTask = entry.value;
                        return ListTile(
                          title: Text(subTask.title),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _subTasks.removeAt(index);
                              });
                            },
                          ),
                          leading: Checkbox(
                            value: subTask.isChecked,
                            onChanged: (value) {
                              setState(() {
                                _subTasks[index] = SubTask(
                                  title: subTask.title,
                                  isChecked: value ?? false,
                                );
                              });
                            },
                          ),
                        );
                      }).toList(),

                      // Field to add new sub-task
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subTaskController,
                              decoration: const InputDecoration(
                                hintText: 'Add a sub-task',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              if (_subTaskController.text.isNotEmpty) {
                                setState(() {
                                  _subTasks.add(
                                    SubTask(title: _subTaskController.text),
                                  );
                                  _subTaskController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reminder section
              SwitchListTile(
                title: const Text('Add Reminder'),
                value: _hasReminder,
                onChanged: (bool value) {
                  setState(() {
                    _hasReminder = value;
                    if (!value) {
                      _date = null;
                      _time = null;
                    }
                  });
                },
              ),

              if (_hasReminder) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _date ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _date = pickedDate;
                            });
                          }
                        },
                        child: Text(_date == null
                            ? 'Select Date'
                            : 'Date: ${_date!.day}/${_date!.month}/${_date!.year}'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: _time ?? TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              _time = pickedTime;
                            });
                          }
                        },
                        child: Text(_time == null
                            ? 'Select Time'
                            : 'Time: ${_time!.format(context)}'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Notes section
              SwitchListTile(
                title: const Text('Add Note'),
                value: _hasNote,
                onChanged: (bool value) {
                  setState(() {
                    _hasNote = value;
                    if (!value) {
                      _noteController.clear();
                    }
                  });
                },
              ),

              if (_hasNote) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
              ],
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final taskProvider =
                        Provider.of<TaskProvider>(context, listen: false);

                    if (_isEditing) {
                      taskProvider.updateTask(
                        id: widget.taskToEdit!.id,
                        title: _titleController.text,
                        description: _descriptionController.text.isEmpty
                            ? null
                            : _descriptionController.text,
                        subTasks: _subTasks,
                        dateTime: _hasReminder ? _dateTime : null,
                        note: _hasNote ? _noteController.text : null,
                        isChecked: widget.taskToEdit!.isChecked,
                      );
                    } else {
                      taskProvider.addTask(
                        title: _titleController.text,
                        description: _descriptionController.text.isEmpty
                            ? null
                            : _descriptionController.text,
                        subTasks: _subTasks,
                        dateTime: _hasReminder ? _dateTime : null,
                        note: _hasNote ? _noteController.text : null,
                      );
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(_isEditing ? 'Save Changes' : 'Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
