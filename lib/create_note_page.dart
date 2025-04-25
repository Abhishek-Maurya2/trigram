import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

class CreateNotePage extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final String? taskId; // If editing an existing note

  const CreateNotePage({
    Key? key,
    this.initialTitle,
    this.initialContent,
    this.taskId,
  }) : super(key: key);

  @override
  _CreateNotePageState createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
      _isEditing = true;
    }
    if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Create Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // Content field
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: const Icon(Icons.save),
        tooltip: 'Save Note',
      ),
    );
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (_isEditing && widget.taskId != null) {
        // Find the task in the provider
        final taskIndex =
            taskProvider.tasks.indexWhere((task) => task.id == widget.taskId);

        if (taskIndex != -1) {
          final task = taskProvider.tasks[taskIndex];

          // Update the existing task
          taskProvider.updateTask(
            id: task.id,
            title: _titleController.text,
            description: task.description,
            subTasks: task.subTasks,
            dateTime: task.dateTime,
            note: _contentController.text,
            isChecked: task.isChecked,
          );
        }
      } else {
        // Create a new task that functions as a note
        taskProvider.addTask(
          title: _titleController.text,
          description: null,
          subTasks: [],
          dateTime: null,
          note: _contentController.text,
        );
      }

      Navigator.pop(context);
    }
  }
}
