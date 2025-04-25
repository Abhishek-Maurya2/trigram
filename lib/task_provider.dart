import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final List<SubTask> subTasks;
  final DateTime? dateTime;
  final String? note;
  final bool isChecked;
  final bool isStandaloneNote; // New flag to indicate a standalone note

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.subTasks,
    this.dateTime,
    this.note,
    this.isChecked = false,
    this.isStandaloneNote =
        false, // Default to false for backward compatibility
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subTasks': subTasks.map((st) => st.toMap()).toList(),
      'dateTime': dateTime?.millisecondsSinceEpoch,
      'note': note,
      'isChecked': isChecked,
      'isStandaloneNote': isStandaloneNote, // Include in map
    };
  }

  static Task fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      subTasks: map['subTasks'] != null
          ? List<SubTask>.from(
              (map['subTasks'] as List).map((x) => SubTask.fromMap(x)))
          : [],
      dateTime: map['dateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateTime'])
          : null,
      note: map['note'],
      isChecked: map['isChecked'] ?? false,
      isStandaloneNote: map['isStandaloneNote'] ?? false, // Read from map
    );
  }
}

class SubTask {
  final String title;
  final bool isChecked;

  SubTask({required this.title, this.isChecked = false});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isChecked': isChecked,
    };
  }

  static SubTask fromMap(Map<String, dynamic> map) {
    return SubTask(
      title: map['title'] ?? '',
      isChecked: map['isChecked'] ?? false,
    );
  }
}

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _sortByNewest = true; // Default: sort by newest first

  List<Task> get tasks {
    final sortedTasks = List<Task>.from(_tasks);
    if (_sortByNewest) {
      // Sort by newest first (assuming tasks are added chronologically)
      sortedTasks.sort((a, b) => b.id.compareTo(a.id));
    } else {
      // Sort by oldest first
      sortedTasks.sort((a, b) => a.id.compareTo(b.id));
    }
    return sortedTasks;
  }

  List<Task> get tasksOnly {
    final filteredTasks =
        _tasks.where((task) => !task.isStandaloneNote).toList();
    if (_sortByNewest) {
      filteredTasks.sort((a, b) => b.id.compareTo(a.id));
    } else {
      filteredTasks.sort((a, b) => a.id.compareTo(b.id));
    }
    return filteredTasks;
  }

  bool get sortByNewest => _sortByNewest;

  void toggleSortOrder() {
    _sortByNewest = !_sortByNewest;
    notifyListeners();
  }

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .get();

    _tasks =
        snapshot.docs.map((doc) => Task.fromMap(doc.id, doc.data())).toList();

    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? description,
    required List<SubTask> subTasks,
    DateTime? dateTime,
    String? note,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .add({
      'title': title,
      'description': description,
      'subTasks': subTasks.map((st) => st.toMap()).toList(),
      'dateTime': dateTime?.millisecondsSinceEpoch,
      'note': note,
      'isChecked': false,
      'isStandaloneNote': false, // Default to false for new tasks
    });

    final task = Task(
      id: docRef.id,
      title: title,
      description: description,
      subTasks: subTasks,
      dateTime: dateTime,
      note: note,
    );

    _tasks.add(task);
    notifyListeners();
  }

  Future<void> addNote({
    required String title,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .add({
      'title': title,
      'description': null,
      'subTasks': [],
      'dateTime': null,
      'note': content,
      'isChecked': false,
      'isStandaloneNote': true, // Mark as a standalone note
    });

    final task = Task(
      id: docRef.id,
      title: title,
      description: null,
      subTasks: [],
      dateTime: null,
      note: content,
      isStandaloneNote: true, // Set this flag to true
    );

    _tasks.add(task);
    notifyListeners();
  }

  void toggleTaskChecked(int index) {
    if (index < 0 || index >= _tasks.length) return;

    final task = _tasks[index];
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      subTasks: task.subTasks,
      dateTime: task.dateTime,
      note: task.note,
      isChecked: !task.isChecked,
      isStandaloneNote: task.isStandaloneNote,
    );

    _tasks[index] = updatedTask;

    _updateTaskInFirestore(updatedTask);
    notifyListeners();
  }

  void toggleSubTaskChecked(int taskIndex, int subTaskIndex) {
    if (taskIndex < 0 || taskIndex >= _tasks.length) return;
    if (subTaskIndex < 0 || subTaskIndex >= _tasks[taskIndex].subTasks.length)
      return;

    final task = _tasks[taskIndex];
    final subTasks = List<SubTask>.from(task.subTasks);
    final oldSubTask = subTasks[subTaskIndex];

    // Create new subtask with toggled isChecked value
    subTasks[subTaskIndex] = SubTask(
      title: oldSubTask.title,
      isChecked: !oldSubTask.isChecked,
    );

    // Create new task with updated subtasks
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      subTasks: subTasks,
      dateTime: task.dateTime,
      note: task.note,
      isChecked: task.isChecked,
      isStandaloneNote: task.isStandaloneNote,
    );

    _tasks[taskIndex] = updatedTask;

    _updateTaskInFirestore(updatedTask);
    notifyListeners();
  }

  Future<void> _updateTaskInFirestore(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  // Get reminders (tasks with dateTime)
  List<Map<String, dynamic>> getReminders() {
    final reminders = _tasks
        .where((task) => task.dateTime != null)
        .map((task) => {
              'id': task.id,
              'title': task.title,
              'time': task.dateTime!,
              'active': !task.isChecked,
            })
        .toList();
    return reminders;
  }

  // Get notes (tasks with note)
  List<Map<String, String>> getNotes() {
    final notes = _tasks
        .where((task) =>
            // Include if it has a note OR if it's a standalone note
            (task.note != null && task.note!.isNotEmpty) ||
            task.isStandaloneNote)
        .map((task) => {
              'title': task.title,
              'content': task.note ?? '',
              'id': task.id,
            })
        .toList();
    return notes;
  }

  Future<void> updateTask({
    required String id,
    required String title,
    String? description,
    required List<SubTask> subTasks,
    DateTime? dateTime,
    String? note,
    required bool isChecked,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updatedTask = Task(
      id: id,
      title: title,
      description: description,
      subTasks: subTasks,
      dateTime: dateTime,
      note: note,
      isChecked: isChecked,
      isStandaloneNote: false, // Default to false for updated tasks
    );

    // Find and update task in local list
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }

    // Update in Firestore
    await _updateTaskInFirestore(updatedTask);
    notifyListeners();
  }

  // Add method to update a note
  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Find the existing task
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final existingTask = _tasks[index];
    final wasStandaloneNote = existingTask.isStandaloneNote;

    final updatedTask = Task(
      id: id,
      title: title,
      description: existingTask.description,
      subTasks: existingTask.subTasks,
      dateTime: existingTask.dateTime,
      note: content,
      isChecked: existingTask.isChecked,
      isStandaloneNote: wasStandaloneNote, // Preserve the original status
    );

    _tasks[index] = updatedTask;
    await _updateTaskInFirestore(updatedTask);
    notifyListeners();
  }
}
